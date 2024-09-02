local M = {}

local CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)

-- From LazyVim
-- This is a better implementation of `cmp.confirm`:
--  * check if the completion menu is visible without waiting for running sources
--  * create an undo point before confirming
-- This function is both faster and more reliable.
---@param opts? {select: boolean, behavior: cmp.ConfirmBehavior}
M.confirm = function(opts)
    local cmp = require("cmp")

    opts = vim.tbl_extend("force", {
        select = true,
        behavior = cmp.ConfirmBehavior.Insert,
    }, opts or {})

    -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#safely-select-entries-with-cr
    return function(fallback)
        if cmp.core.view:visible() or vim.fn.pumvisible() == 1 then
            --
            if vim.api.nvim_get_mode().mode == "i" then
                vim.api.nvim_feedkeys(CREATE_UNDO, "n", false)
            end

            if cmp.confirm(opts) then
                return
            end
        end
        return fallback()
    end
end

-- change buffers source in nvim-cmp
M.get_bufnrs = function()
    local cmp_get_bufnrs = vim.g.cmp_get_bufnrs
    local bufs = {}

    -- Current buffer
    if cmp_get_bufnrs == "current_buf" then
        table.insert(bufs, vim.api.nvim_get_current_buf())
        return bufs
    end

    -- buffers in current tab including unlisted ones like help
    if cmp_get_bufnrs == "current_tab" then
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            table.insert(bufs, vim.api.nvim_win_get_buf(win))
        end

        return bufs
    end

    -- All active/listed non-empty buffers or all buffers including hidden/unlisted ones (like help/terminal)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
            (cmp_get_bufnrs == "buflisted" and vim.api.nvim_get_option_value("buflisted", { buf = buf }) or cmp_get_bufnrs == "all")
            and vim.api.nvim_buf_is_loaded(buf)
            and vim.api.nvim_buf_line_count(buf) > 0
        then
            table.insert(bufs, buf)
        end
    end

    return bufs
end

-- Only show matches in strings and comments.
M.is_string_like = function()
    local context = require("cmp.config.context")

    return context.in_treesitter_capture("comment")
        or context.in_treesitter_capture("string")
        or context.in_syntax_group("Comment")
        or context.in_syntax_group("String")
end

return M
