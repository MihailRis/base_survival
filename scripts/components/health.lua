local health = ARGS.health or ARGS.max_health or SAVED_DATA.health
local max_health = ARGS.max_health or SAVED_DATA.max_health

function get_health()
    return health
end

function on_save()
    SAVED_DATA.health = health
    SAVED_DATA.max_health = max_health
end
