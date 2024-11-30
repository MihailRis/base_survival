local gamemodes = {
    players = {}
}

function gamemodes.get_player_health(playerid)
    local entity = entities.get(player.get_entity(playerid))
    return entity:get_component("base_survival:health")
end


function gamemodes.set(playerid, name)
    local gamemode = gamemodes.get(playerid)
    if name == "developer" then
        rules.set("allow-cheat-movement", true)
        rules.set("allow-flight", true)
        rules.set("allow-noclip", true)
        rules.set("allow-debug-cheats", true)
        rules.set("allow-fast-interaction", true)
        rules.set("allow-content-access", true)
        rules.set("allow-destroy", true)
        player.set_instant_destruction(playerid, true)
        player.set_infinite_items(playerid, true)
    elseif name == "survival" then
        rules.set("allow-cheat-movement", false)
        rules.set("allow-flight", false)
        rules.set("allow-noclip", false)
        rules.set("allow-debug-cheats", false)
        rules.set("allow-fast-interaction", false)
        rules.set("allow-content-access", false)
        rules.set("allow-destroy", true)
        player.set_instant_destruction(playerid, false)
        player.set_infinite_items(playerid, false)
        player.set_flight(playerid, false)
        player.set_noclip(playerid, false)
    end
    gamemode.current = name
    events.emit("base_survival:gamemodes.set", playerid, name)
end

function gamemodes.exists(name)
    return name == "developer" or name == "survival"
end

function gamemodes.get(playerid)
    if gamemodes.players[playerid] == nil then
        gamemodes.players[playerid] = {
            current=player.is_infinite_items(playerid)
            and "developer" or "survival"}
        events.emit("base_survival:gamemodes.set", playerid, 
                    gamemodes.players[playerid].current)
    end
    return gamemodes.players[playerid]
end

return gamemodes
