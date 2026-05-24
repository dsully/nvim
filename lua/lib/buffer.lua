local M = {}

---Retrieves the current visual selection as a string using Neovim's modern Lua API.
---
---@param bufnr integer?
---@return string[] Selected text as a string, or nil if not in visual mode or selection is empty.
function M.visual_selection(bufnr)
    vim.cmd.normal({ "v", bang = true })

    bufnr = bufnr or 0

    local start = vim.api.nvim_buf_get_mark(bufnr, "<")
    local finish = vim.api.nvim_buf_get_mark(bufnr, ">")

    if start[1] == 0 or finish[1] == 0 then
        return {}
    end

    return vim.api.nvim_buf_get_text(bufnr, start[1] - 1, start[2], finish[1] - 1, finish[2] + 1, {})
end

---@param bufnr integer?
function M.code_block(bufnr)
    local lines = M.visual_selection(bufnr)

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
    if min_indent ~= math.huge then
        for i, line in ipairs(lines) do
            if line:match("%S") then
                lines[i] = line:sub(math.floor(min_indent) + 1)
            end
        end
    end

    return table.concat(lines, "\n")
end

-- Unsaved-buffer confirmation is handled with Neovim's native `confirm()`: a
-- `vim.ui.select` (snacks) prompt renders broken, and floating-window prompts
-- don't survive while noice owns rendering. We use `confirm()` for the decision
-- and `mini.bufremove` for the layout-preserving deletion (with `force`, since
-- we've already handled the unsaved changes).
---@param bufnr integer?
function M.delete_buffer(bufnr)
    local target = (bufnr and bufnr ~= 0) and bufnr or vim.api.nvim_get_current_buf()
    local delete = require("mini.bufremove").delete

    -- Switch the current window to the display-order neighbor first, so
    -- mini.bufremove keeps focus adjacent instead of jumping to the last buffer.
    local function remove()
        if target == vim.api.nvim_get_current_buf() then
            local sibling = require("lib.tabline").sibling(target)

            if sibling then
                vim.api.nvim_set_current_buf(sibling)
            end
        end

        delete(target, true)
    end

    if not vim.bo[target].modified then
        remove()
        return
    end

    local name = vim.api.nvim_buf_get_name(target)
    local label = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"

    local choice = vim.fn.confirm(string.format('Buffer "%s" has unsaved changes.', label), "&Save and close\n&Discard and close\n&Cancel", 3)

    if choice == 1 then
        if name == "" then
            vim.notify("Buffer has no name; save it manually first.", vim.log.levels.WARN)
            return
        end

        vim.api.nvim_buf_call(target, function()
            vim.cmd.write()
        end)

        remove()
    elseif choice == 2 then
        remove()
    end
end

return M
