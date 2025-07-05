local M = {}

---@param bufnr integer?
M.code_block = function(bufnr)
    vim.cmd.normal({ "v", bang = true })

    bufnr = bufnr or 0

    local line_s = vim.api.nvim_buf_get_mark(bufnr, "<")[1] or 0
    local line_e = vim.api.nvim_buf_get_mark(bufnr, ">")[1] or 0
    local lines = vim.api.nvim_buf_get_lines(bufnr, line_s - 1, line_e, true)

    -- Find minimum indentation
    local min_indent = math.huge

    for _, line in ipairs(lines) do
        if line:match("%S") then -- Skip empty lines
            local ws = line:match("^%s*")
            if ws then
                min_indent = math.min(min_indent, ws:len())
            end
        end
    end

    -- Dedent lines
    for i, line in ipairs(lines) do
        if line:match("%S") then
            lines[i] = line:sub(math.floor(min_indent) + 1)
        end
    end

    return table.concat(lines, "\n")
end

return M
