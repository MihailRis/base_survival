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
    local material = block.material(id)
    if material == "base:ground" or 
       material == "base:grass_block" or 
       material == "base:sand" then
        return 0.7
    elseif material == "base:glass" then
        return 0.4
    elseif material == "base:grass" then
        return 1.0
    end
    return 5.0
end

local function get_drop(id, playerid)
    return block.get_picking_item(id), 1
end

local function stop_breaking(target)
    events.emit("base_survival:stop_destroy", playerid, target)
    target.breaking = false
end

function on_player_tick(playerid, tps)
    if gamemodes.get(playerid).current ~= "survival" then
        return
    end
    local target = breaking_blocks[playerid]
    if not target then
        target = {breaking=false}
        breaking_blocks[playerid] = target
    end

    if input.is_active("player.destroy") then
        local x, y, z = player.get_selected_block(playerid)
        if target.breaking then
            if block.get(x, y, z) ~= target.id or 
               x ~= target.x or y ~= target.y or z ~= target.z then
                return stop_breaking(target)
            end
            local speed = 1.0 / math.max(get_durability(target.id), 0.00001)
            target.progress = target.progress + (1.0/tps) * speed
            target.tick = target.tick + 1
            if target.progress >= 1.0 then
                block.destruct(x, y, z, playerid)
                return stop_breaking(target)
            end
            events.emit("base_survival:progress_destroy", playerid, target)
        elseif x ~= nil then
            target.breaking = true
            target.id = block.get(x, y, z)
            target.x = x
            target.y = y
            target.z = z
            target.tick = 0
            target.progress = 0.0
            events.emit("base_survival:start_destroy", playerid, target)
        end
    elseif target.wrapper then
        stop_breaking(target)
    end
end

function on_block_broken(id, x, y, z, playerid)
    if gamemodes.get(playerid).current ~= "survival" then
        return
    end
    local dropid, count = get_drop(id, playerid)
    base_util.drop({x + 0.5, y + 0.5, z + 0.5}, dropid, count)
end
