local gamemodes = require "gamemodes"
local base_util = require "base:util"

local health = SAVED_DATA.health or ARGS.health or ARGS.max_health or 20
local max_health = SAVED_DATA.max_health or ARGS.max_health or 20

health = math.ceil(health)

function get_health()
    return health or 20
end

function get_max_health()
    return max_health
end

function set_health(value)
    health = math.min(math.max(0, value), max_health)
    events.emit("base_survival:health.set", entity, health)
end

local function drop_inventory(invid)
    local pos = entity.transform:get_pos()
    local size = inventory.size(invid)
    for i=0,size-1 do
        local itemid, count = inventory.get(invid, i)
        if itemid ~= 0 then
            local data = inventory.get_all_data(invid, i)
            local drop = base_util.drop(pos, itemid, count, data)
            drop.rigidbody:set_vel(vec3.spherical_rand(8.0))
            inventory.set(invid, i, 0)
        end
    end
end

function die()
    events.emit("base_survival:death", entity)
    events.emit("base_survival:player_death", entity:get_player(), true)

    local pid = entity:get_player()
    if not rules.get("keep-inventory") then
        drop_inventory(player.get_inventory(pid))
    end
    entity:despawn()
    player.set_entity(pid, 0)
end

function heal(points)
    local pid = entity:get_player()
    if points < 1 and pid then
        events.emit("base_survival:player_heal", pid, points)
    end
    set_health(math.min(health + points, max_health))
end

function damage(points)
    local pid = entity:get_player()
    if gamemodes.get(pid).current == "developer" then
        return
    end
    if points > 0 and pid then
        events.emit("base_survival:player_damage", pid, points)
    end
    set_health(health - points)
    if health == 0 then
        die()
    end
end

function on_save()
    SAVED_DATA.health = health
    SAVED_DATA.max_health = max_health
end

function on_grounded(force)
    local dmg = math.floor((force - 12) * 1.1)
    damage(math.max(0, math.floor(dmg)))
end
