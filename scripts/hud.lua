local gamemodes = require "gamemodes"

function on_hud_open()
    hud.open_permanent("base_survival:health_bar")

    console.add_command("gamemode player:sel=$obj.id name:str=''", 
    "Set game mode",
    function (args, kwargs)
        local playerid = args[1] or hud.get_player()
        local name = args[2]
        if #name == 0 then
            return "current game mode is ["..gamemodes.get(playerid).current.."]"
        end
        if gamemodes.exists(name) then
            gamemodes.set(playerid, name)
            return "set game mode to ["..name.."]"
        else
            return "error: game mode ["..name.."] does not exists"
        end
    end)

    events.on("base_survival:start_destroy", function(playerid, target)
        target.wrapper = gfx.blockwraps.wrap(
            {target.x, target.y, target.z}, "cracks/cracks_0"
        )
    end)

    events.on("base_survival:progress_destroy", function(playerid, target)
        local x = target.x
        local y = target.y
        local z = target.z
        gfx.blockwraps.set_texture(target.wrapper, string.format(
            "cracks/cracks_%s", math.floor(target.progress * 11)
        ))
        if target.tick % 12 == 0 then
            audio.play_sound(block.materials[block.material(target.id)].stepsSound, 
                x + 0.5, y + 0.5, z + 0.5, 1.0, 1.0, "regular"
            )
            local camera = cameras.get("core:first-person")
            local ray = block.raycast(camera:get_pos(), camera:get_front(), 64.0)
            gfx.particles.emit(ray.endpoint, 4, {
                lifetime=1.0,
                spawn_interval=0.0001,
                explosion={3, 3, 3},
                velocity=vec3.add(vec3.mul(camera:get_front(), -1.0), {0,0.5,0}),
                texture="blocks:"..block.get_textures(target.id)[1],
                random_sub_uv=0.1,
                size={0.1, 0.1, 0.1},
                size_spread=0.2,
                spawn_shape="box",
                collision=true
            })
        end
    end)

    events.on("base_survival:stop_destroy", function(playerid, target)
        gfx.blockwraps.unwrap(target.wrapper)
    end)
end
