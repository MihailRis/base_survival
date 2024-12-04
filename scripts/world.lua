local base_util = require "base:util"
local gamemodes = require "gamemodes"

local breaking_blocks = {}

local function get_durability(id)
    local durability = block.properties[id]["base:durability"]
    if durability ~= nil then
        return durability
    end
    if block.get_model(id) == "X" then
        return 0.0
    end
    return 5.0
end

local function get_drop(id, pid)
    return block.get_picking_item(id), 1
end

local function stop_breaking(target)
    events.emit("base_survival:stop_destroy", pid, target)
    target.breaking = false
end

function on_player_tick(pid, tps)
    local gamemode = gamemodes.get(pid).current
    local phealth = gamemodes.get_player_health(pid)
    phealth.set_player(pid)

    if gamemode ~= "survival" then
        return
    end
    local target = breaking_blocks[pid]
    if not target then
        target = {breaking=false}
        breaking_blocks[pid] = target
    end

    if input.is_active("player.destroy") then
        local x, y, z = player.get_selected_block(pid)
        if target.breaking then
            if block.get(x, y, z) ~= target.id or 
               x ~= target.x or y ~= target.y or z ~= target.z then
                return stop_breaking(target)
            end
            local speed = 1.0 / math.max(get_durability(target.id), 0.00001)
            target.progress = target.progress + (1.0/tps) * speed
            target.tick = target.tick + 1
            if target.progress >= 1.0 then
                block.destruct(x, y, z, pid)
                return stop_breaking(target)
            end
            events.emit("base_survival:progress_destroy", pid, target)
        elseif x ~= nil then
            target.breaking = true
            target.id = block.get(x, y, z)
            target.x = x
            target.y = y
            target.z = z
            target.tick = 0
            target.progress = 0.0
            events.emit("base_survival:start_destroy", pid, target)
        end
    elseif target.wrapper then
        stop_breaking(target)
    end
end

function on_block_broken(id, x, y, z, pid)
    if pid == -1 then
        return
    end
    if gamemodes.get(pid).current ~= "survival" then
        return
    end
    local dropid, count = get_drop(id, pid)
    base_util.drop({x + 0.5, y + 0.5, z + 0.5}, dropid, count)
end
