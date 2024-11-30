local gamemodes = require "gamemodes"
local base_util = require "base:util"

local health = SAVED_DATA.health or ARGS.health or ARGS.max_health or 20
local max_health = SAVED_DATA.max_health or ARGS.max_health or 20

health = math.ceil(health)

local fall_timer = 0.0

immortal = false
spawnpoint = nil
invid = nil

function get_health()
    return health or 15
end

function set_health(value)
    health = math.min(math.max(0, value), max_health)
    events.emit("base_survival:health.set", entity, health)
end

function die()
    set_health(max_health)
    if invid then
        local pos = entity.transform:get_pos()
        local size = inventory.size(invid)
        for i=0,size-1 do
            local itemid, count = inventory.get(invid, i)
            if itemid ~= 0 then
                base_util.drop(pos, itemid, count).rigidbody:set_vel(vec3.spherical_rand(5.0))
                inventory.set(invid, 0, 0)
            end
        end
    end
    if spawnpoint then
        entity.transform:set_pos(spawnpoint)
    end
    events.emit("base_survival:death", entity)
end

function damage(points)
    if immortal then
        return
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
    local dmg = 5 * fall_timer * fall_timer - 3
    damage(math.max(0, math.floor(dmg)))
end

function on_update(tps)
    fall_timer = fall_timer + 1.0 / tps
end

function on_fall()
    fall_timer = 0.0
end
