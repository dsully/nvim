local M = {}

-- https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#run-the-first-available-formatter-followed-by-more-formatters
---@param bufnr integer
---@param ... string
---@return string
M.first = function(bufnr, ...)
    local conform = require("conform")

    for i = 1, select("#", ...) do
        local formatter = select(i, ...)

        if conform.get_formatter_info(formatter, bufnr).available then
            return formatter
        end
    end

    return select(1, ...)
end

return M
