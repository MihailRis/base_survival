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
            base_util.drop(pos, itemid, count).rigidbody:set_vel(vec3.spherical_rand(5.0))
            inventory.set(invid, i, 0)
        end
    end
end

function die()
    events.emit("base_survival:death", entity)

    local pid = entity:get_player()
    if pid == hud.get_player() then
        if not rules.get("keep-inventory") then
            drop_inventory(player.get_inventory(pid))
        end
        hud.close_inventory()
        entity:despawn()
        player.set_entity(pid, 0)
        gui.alert("You are dead", function ()
            player.set_pos(pid, player.get_spawnpoint(pid))
            player.set_rot(pid, 0, 0, 0)
            player.set_entity(pid, -1)
            menu:reset()
        end)
    end
end

function damage(points)
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
