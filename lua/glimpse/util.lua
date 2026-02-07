local M = {}

---Complete input line with selection
---@param input string Current input
---@param selection string Selected item
---@return string completed Completed line
function M.complete_line(input, selection)
    if vim.startswith(selection, input) then
        return selection
    end

    local prefix = input:match("^(.*[%s%.%/:\\])" or "") or ""

    return prefix .. selection
end

---@class glimpse.Schema
---@field pattern string|string[]
---@field keys string[]
---@field types table<string, fun(val: string|number): number?>

---@type table<string,glimpse.Schema>
M.schemas = {
    grep = {
        pattern = "^(.-):(%d+):(%d+):(.*)",
        keys = { "filename", "lnum", "col", "content" },
        types = { lnum = tonumber, col = tonumber },
    },
    file = {
        pattern = "^(.*)",
        keys = { "filename" },
        types = {},
    },
}

---@param selection string
---@param format string
---@return table?
function M.parse_selection(selection, format)
    if not selection or selection == "" then
        return nil
    end

    local schema = M.schemas[format]

    if not schema then
        return nil
    end

    local patterns = type(schema.pattern) == "table" and schema.pattern or { schema.pattern }

    ---@type string[]|number[]
    local matches = {}

    for _, pat in ipairs(patterns) do
        matches = { selection:match(pat) }

        if #matches > 0 then
            break
        end
    end

    if #matches == 0 then
        return nil
    end

    ---@type table<string, string|number>
    local result = {}

    for i, key in ipairs(schema.keys) do
        local val = matches[i]

        if val then
            ---@type (fun(v: string|number): number?)?
            local convert = schema.types[key]
            result[key] = convert and convert(val) or val
        end
    end

    result.lnum = result.lnum or 1
    result.col = result.col or 1

    return result
end

M.parsers = {
    file = function(selection)
        return M.parse_selection(selection, "file")
    end,
    grep = function(selection)
        return M.parse_selection(selection, "grep")
    end,
}

---@param selection string
---@param data_or_format string|table?
function M.jump_to_location(selection, data_or_format)
    local data = data_or_format

    if type(data_or_format) == "string" then
        data = M.parse_selection(selection, data_or_format)
    end

    if data and data.filename then
        -- vim.cmd.edit(nvim.file.normalize(data.filename))
        vim.cmd.edit(data.filename)

        if data.lnum and data.col then
            ---@type integer
            local lnum = data.lnum
            ---@type integer
            local col = math.floor(math.max(0, data.col - 1))

            vim.api.nvim_win_set_cursor(0, { lnum, col })
        end
    end
end

return M
