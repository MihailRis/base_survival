local gamemodes = require "gamemodes"
local survival_hud = require "survival_hud"

local death_ambient
local isdead = false

function on_hud_open()
    events.on("base_survival:gamemodes.set", function(playerid, name)
        if name == "survival" then
            hud.open_permanent("base_survival:health_bar")

            local entity = entities.get(player.get_entity(playerid))
            if not entity then
                return -- dead
            end
            local health = entity:get_component("base_survival:health")
            survival_hud.set_health(health.get_health())
        else
            hud.close("base_survival:health_bar")
        end
    end)
    events.on("base_survival:health.set", function(entity, health)
        if entity:get_uid() == player.get_entity(hud.get_player()) then
            survival_hud.set_health(health)
        end
    end)

    console.add_command("gamemode player:sel=$obj.id name:str=''", 
    "Set game mode",
    function (args, kwargs)
        local pid = args[1] or hud.get_player()
        local name = args[2]
        if #name == 0 then
            return "current game mode is ["..gamemodes.get(pid).current.."]"
        end
        if gamemodes.exists(name) then
            gamemodes.set(pid, name)
            return "set game mode to ["..name.."]"
        else
            return "error: game mode ["..name.."] does not exists"
        end
    end)

    events.on("base_survival:start_destroy", function(pid, target)
        target.wrapper = gfx.blockwraps.wrap(
            {target.x, target.y, target.z}, "cracks/cracks_0"
        )
    end)

    events.on("base_survival:progress_destroy", function(pid, target)
        local x = target.x
        local y = target.y
        local z = target.z
        gfx.blockwraps.set_texture(target.wrapper, string.format(
            "cracks/cracks_%s", math.floor(target.progress * 11)
        ))
        if target.tick % 4 == 0 then
            local material = block.materials[block.material(target.id)]
            audio.play_sound(
                target.power >= 1.2 and
                    material.hitSound or
                    material.stepsSound, 
                x + 0.5, y + 0.5, z + 0.5,
                1.0, 0.9 + math.random() * 0.2, "regular"
            )
            local cam = cameras.get("core:first-person")
            local front = cam:get_front()
            local ray = block.raycast(cam:get_pos(), front, 64.0)
            gfx.particles.emit(ray.endpoint, 4, {
                lifetime=1.0,
                spawn_interval=0.0001,
                explosion={3, 3, 3},
                velocity=vec3.add(vec3.mul(front, -1.0), {0, 0.5, 0}),
                texture="blocks:"..block.get_textures(target.id)[1],
                random_sub_uv=0.1,
                size={0.1, 0.1, 0.1},
                size_spread=0.2,
                spawn_shape="box",
                collision=true
            })
        end
    end)

    events.on("base_survival:stop_destroy", function(pid, target)
        gfx.blockwraps.unwrap(target.wrapper)
    end)

    events.on("base_survival:player_death", function(pid, just_happened)
        if just_happened then
            local pos = cameras.get(player.get_camera(pid)):get_pos()
            audio.play_sound(
                "events/huge_damage",
                pos[1], pos[2], pos[3],
                1.0, 
                0.8 + math.random() * 0.4, 
                "regular"
            )
        end
        if pid ~= hud.get_player() then
            return
        end
        isdead = true
        
        hud.close_inventory()
        if just_happened then
            local px, py, pz = player.get_pos(pid)
            player.set_pos(pid, px, py - 0.7, pz)
        end
        gui.alert("You are dead", function ()
            player.set_pos(pid, player.get_spawnpoint(pid))
            player.set_rot(pid, 0, 0, 0)
            player.set_entity(pid, -1)
            menu:reset()

            audio.stop(death_ambient)
            death_ambient = nil
            isdead = false
        end)
        death_ambient = audio.play_stream_2d(
            "sounds/ambient/death.ogg", 1.0, 0.5, "ambient", true
        )
    end)
    events.on("base_survival:player_damage", function(pid, points)
        if pid ~= hud.get_player() then
            return
        end
        audio.play_sound_2d(
            "events/damage", 0.5, 1.0 + math.random() * 0.4, "regular"
        )
        local x, y, z = player.get_rot(pid)
        player.set_rot(pid, x, y, math.random() < 0.5 and 13 or -13)
    end)
end

function on_hud_render()
    local pid = hud.get_player()
    if gamemodes.is_dead(pid) then
        if not isdead then
            events.emit("base_survival:player_death", pid)
        end
        local rx, ry, rz = player.get_rot(pid)
        local t = time.delta() * 75
        player.set_rot(pid, rx, ry, rz * (1.0 - t) + 45 * t)
    else
        local x, y, z = player.get_rot(pid)
        local dt = math.min(time.delta() * 12, 1.0)
        player.set_rot(pid, x, y, z * (1.0 - dt)) 
    end
end
