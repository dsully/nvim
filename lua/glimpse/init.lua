local Picker = require("glimpse.picker")

local M = {}

---Open a picker with a static list of items
---@param items string[] List of strings
---@param opts GlimpseOptions|nil Options
---@return Picker picker The picker instance
function M.pick(items, opts)
    local picker = Picker.new(items, opts)
    picker:show()

    return picker
end

---Open an async picker with a command generator
---@param command_generator fun(query: string): string[]|nil Function that returns command args based on query
---@param opts GlimpseOptions|nil Options
---@return Picker picker The picker instance
function M.pick_async(command_generator, opts)
    local picker = Picker.new_async(command_generator, opts)
    picker:show()

    return picker
end

return M
