local M = {}

local blink = require("glimpse.blink")

--- Register items with Blink's Rust engine
---@param items string[] List of strings
function M.register_items(items)
    local blink_items = {}

    for _, item in ipairs(items) do
        table.insert(blink_items, { label = item, sortText = item })
    end

    blink.set_provider_items("glimpse", blink_items)
end

--- Filter items based on query
---@param items_or_provider table|function List of strings or a function(query)
---@param query string The search query
---@return table matches List of matching strings
function M.filter(items_or_provider, query)
    if type(items_or_provider) == "function" then
        return items_or_provider(query)
    end

    if query == "" then
        return items_or_provider
    end

    M.register_items(items_or_provider)

    local _, matched_indices = blink.fuzzy(query, "glimpse")

    if matched_indices then
        local matches = {}

        for _, idx in ipairs(matched_indices) do
            table.insert(matches, items_or_provider[idx + 1])
        end

        return matches
    end

    return {}
end

return M
