local gamemodes = require "gamemodes"
local base_util = require "base:util"

local health = SAVED_DATA.health or ARGS.health or ARGS.max_health or 20
local max_health = SAVED_DATA.max_health or ARGS.max_health or 20

health = math.ceil(health)

function get_health()
    return health or 20
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
            local drop = base_util.drop(pos, itemid, count)
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

function damage(points)
    if points > 0 and entity:get_player() == hud.get_player() then
        audio.play_sound_2d("events/damage", 0.5, 1.0 + math.random() * 0.4, "regular")
        local x, y, z = player.get_rot(pid)
        player.set_rot(pid, x, y, math.random() < 0.5 and 13 or -13)
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
    local dmg = math.floor((force - 12) * 0.75)
    damage(math.max(0, math.floor(dmg)))
end
