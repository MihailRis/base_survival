local crafting = require "crafting"

local controller = {
    stats = {},
    invsize = 0,
    max_crafts = 0,
}

local CRAFT_ROWS = 3
local CRAFT_COLS = 5
local craft_buttons = {}

local function display_craft(craft, button, stats)
    for _, node in ipairs(button) do
        node.visible = true
        node.src = item.icon(item.index(craft.results[1].id))
        break
    end
    button.enabled = crafting.is_enough(craft, stats)
end

local function refresh_crafts(invid)
    local stats = {}
    local invsize = inventory.size(invid)

    local shown_crafts = {}
    for i=0,invsize-1 do
        local id, count = inventory.get(invid, i)
        stats[id] = (stats[id] or 0) + count

        local name = item.name(id)

        local found = crafting.find_all_containing(name)
        for j, craft in ipairs(found) do
            if not table.has(shown_crafts, craft) then
                table.insert(shown_crafts, craft)
            end
        end
    end
    controller.stats = stats
    controller.invsize = invsize
    controller.shown_crafts = shown_crafts

    local shown_crafts_count = math.min(controller.max_crafts, #shown_crafts)
    for i=0,shown_crafts_count-1 do
        local craft = shown_crafts[i + 1]
        local craft_button = craft_buttons[i + 1]
        display_craft(craft, craft_button, stats)
    end
    for i=shown_crafts_count,controller.max_crafts-1 do
        local craft_button = craft_buttons[i + 1]
        for _, node in ipairs(craft_button) do
            node.visible = false
            break
        end
        craft_button.enabled = false
    end
end

function on_items_update(invid, slotid)
    refresh_crafts(invid)
end

function on_open(invid)
    controller.invid = invid
    if controller.max_crafts == 0 then
        for row=0, CRAFT_ROWS-1 do
            for col=0, CRAFT_COLS-1 do
                local index = row * CRAFT_COLS + col
                document.root:add(gui.template("craft_button", {
                    x = 150 + col * 50,
                    y = 5 + row * 50,
                    index = index,
                }), controller)
                controller.max_crafts = controller.max_crafts + 1
                table.insert(craft_buttons, document["craft_slot_"..index])
            end
        end
    end
    refresh_crafts(invid)
end

function controller:craft(index)
    local pid = hud.get_player()
    local pinvid = player.get_inventory(pid)
    local craft = self.shown_crafts[index + 1]
    crafting.remove_from(craft, self.invid)
    refresh_crafts(self.invid)
    for i, result in ipairs(craft.results) do
        local overflow = inventory.add(self.invid, item.index(result.id), result.count)
        if overflow > 0 then
            inventory.add(pinvid, item.index(result.id), overflow)
        end
    end
end
