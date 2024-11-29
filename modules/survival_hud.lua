local survival_hud = {}

function survival_hud.get_player_health(playerid)
    local entity = entities.get(player.get_entity(playerid))
    return entity:get_component("base_survival:health")
end

return survival_hud
