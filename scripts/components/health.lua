local health = SAVED_DATA.health or ARGS.health or ARGS.max_health or 20
local max_health = SAVED_DATA.max_health or ARGS.max_health or 20

function get_health()
    return health or 15
end

function set_health(value)
    health = math.min(math.max(0, value), max_health)
    events.emit("base_survival:health.set", entity, health)
end

function on_save()
    SAVED_DATA.health = health
    SAVED_DATA.max_health = max_health
end
