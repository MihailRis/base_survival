local survival_hud = require "survival_hud"

function survival_hud.set_health(health)
    for i=1,10 do
        local img = "gui/health_point"
        if i * 2 - 1 == health then
            img = "gui/health_point_half"
        elseif i * 2 > health then
            img = "gui/health_point_off"
        end
        document["hp_"..tostring(i - 1)].src = img
    end
end

function on_open()
    local health = survival_hud.get_health_component(hud.get_player())
    survival_hud.set_health(health.get_health())
end
