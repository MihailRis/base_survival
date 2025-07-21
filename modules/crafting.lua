local crafting = {}

crafting.crafts = file.read_combined_list("crafts.json")

function crafting.find_all_containing(id)
    local found = {}
    for i, craft in ipairs(crafting.crafts) do
        for j, comp in ipairs(craft.components or {}) do
            if comp.id == id then
                table.insert(found, craft)
                break
            end
        end
    end
    return found
end

function crafting.is_enough(craft, stats)
    for i, comp in ipairs(craft.components) do
        local id = item.index(comp.id)
        if (stats[id] or 0) < comp.count then
            return false
        end
    end
    return true
end

local function remove_item(invid, itemid, itemcount)
    local size = inventory.size(invid)
    for i=0,size-1 do
        local id, count = inventory.get(invid, i)
        if id ~= itemid then
            goto continue
        end
        local decrement = math.min(itemcount, count)
        inventory.decrement(invid, i, decrement)
        ::continue::
    end
end

function crafting.remove_from(craft, invid)
    for i, comp in ipairs(craft.components) do
        remove_item(invid, item.index(comp.id), comp.count)
    end
end

return crafting
