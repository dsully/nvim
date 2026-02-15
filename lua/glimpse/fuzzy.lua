local M = {}

local blink = require("glimpse.blink")

---@type string[]?
local registered_items = nil

--- Register items with Blink's Rust engine
---@param items string[] List of strings
function M.register_items(items)
    if items == registered_items then
        return
    end

    registered_items = items

    local blink_items = {}

    for _, item in ipairs(items) do
        table.insert(blink_items, { label = item, sortText = item })
    end

    blink.set_provider_items("glimpse", blink_items)
end

--- Filter items based on query
---@param items table List of strings
---@param query string The search query
---@return string[] matches List of matching strings
function M.filter(items, query)
    if query == "" then
        return items
    end

    M.register_items(items)

    local _, matched_indices = blink.fuzzy(query, "glimpse")

    if matched_indices then
        local matches = {}

        for _, idx in ipairs(matched_indices) do
            table.insert(matches, items[idx + 1])
        end

        return matches
    end

    return {}
end

return M
