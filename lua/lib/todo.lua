local M = {}

---@type table<string, string[]>
local groups = {
    TodoError = { "BUG", "BROKEN", "FIX", "FIXME", "ISSUE" },
    TodoWarn = { "HACK", "WARN", "WARNING", "XXX" },
    TodoInfo = { "TODO", "NB" },
    TodoHint = { "NOTE", "INFO", "PERF" },
    TodoTest = { "IDEA", "TEST", "EXPERIMENT", "TESTING" },
}

---@param keywords string[]?
---@return string
local function alternation(keywords)
    return table.concat(keywords or vim.iter(vim.tbl_values(groups)):flatten():totable(), "|")
end

---Highlight `KEYWORD:` and `KEYWORD(owner):`.
---@return table<string, MiniHipatterns.Highlighter>
function M.highlighters()
    local ret = {}

    for group, words in pairs(groups) do
        for _, word in ipairs(words) do
            ret["todo_" .. word] = {
                pattern = { "%f[%w]()" .. word .. ":()", "%f[%w]()" .. word .. "%b():()" },
                group = group,
            }
        end
    end

    return ret
end

---@param backward boolean?
function M.jump(backward)
    vim.fn.search([[\v<(]] .. alternation() .. [[)(\([^)]*\))?:]], backward and "bs" or "s")
end

---@param keywords string[]?
function M.pick(keywords)
    Snacks.picker.grep({
        live = false,
        search = [[\b(]] .. alternation(keywords) .. [[)(\([^)]*\))?:]],
        supports_live = true,
        title = "TODOs",
    })
end

return M
