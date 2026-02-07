local M = {}

---Register items with the fuzzy matcher
---@param id string Context ID (e.g. "glimpse")
---@param items table List of items
function M.set_provider_items(id, items)
    require("blink.cmp.fuzzy.rust").set_provider_items(id, items)
end

---Perform fuzzy search
---@param query string
---@param id string Context ID
---@return table|nil matches, table|nil indices
function M.fuzzy(query, id)
    return require("blink.cmp.fuzzy.rust").fuzzy(query, #query, { id }, {
        max_typos = 1,
        use_frecency = true,
        use_proximity = false,
        nearby_words = {},
        match_suffix = false,
        snippet_score_offset = 0,
        sorts = { "score", "sort_text" },
    })
end

return M
