local tsf = entity.transform
local mob = entity:require_component("core:mob")
local pathfinding = entity:require_component("core:pathfinding")

function on_update(tps)
    local pos = tsf:get_pos()
    pathfinding.set_target(vec3.add(pos,
        {math.random(-15*10, 15*10), math.random(-2, 2), math.random(-15*10, 15*10)}))

    pathfinding.set_refresh_interval(300)
    local ppos = {player.get_pos(hud.get_player())}
    if vec3.distance(pos, ppos) < 30 then
        mob.look_at(ppos, false)
    end
    -- pathfinding.set_target(ppos)
    mob.follow_waypoints()

end
