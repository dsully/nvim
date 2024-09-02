local M = {}

local CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)

M.config = {
    buffer = {
        name = "buffer",
        priority = 1,
        group_index = 3,
        keyword_length = 3,
        keyword_pattern = [[\k\+]],
        option = {
            get_bufnrs = M.get_bufnrs,
        },
    },

    -- https://github.com/hrsh7th/nvim-cmp/issues/1511
    cmdline = {
        name = "cmdline",
        keyword_pattern = [=[[^[:blank:]\!]*]=],
        option = {
            ignore_cmds = {},
        },
    },

    env = {
        name = "dotenv",
        priority = 1,
        group_index = 3,
        keyword_length = 3,
        -- keyword_pattern = [[$\+]],
    },

    lazydev = {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
    },

    lsp = function()
        local types = require("cmp.types.lsp")
        local cmp_rs = require("cmp_lsp_rs")

        return {
            name = "nvim_lsp",
            -- https://github.com/hrsh7th/nvim-cmp/pull/1067
            --
            ---@param entry cmp.Entry
            ---@param ctx cmp.Context
            entry_filter = function(entry, ctx)
                local kind = entry:get_kind()
                local line = ctx.cursor_line

                -- Don't complete LSP symbols in comments or strings.
                -- Don't show deprecated items.
                if M.is_string_like() or entry:is_deprecated() then
                    return false
                end

                -- Don't return "Text" types from LSP completion.
                if vim.tbl_contains({ types.CompletionItemKind.Text }, kind) then
                    return false
                end

                -- Better Rust sorting.
                if ctx.filetype == "rust" and cmp_rs.filter_out.rust_filter_out_methods_to_be_imported(entry) then
                    return true
                end

                if string.match(line, "^%s+%w+$") then
                    return kind == types.CompletionItemKind.Function or kind == types.CompletionItemKind.Variable
                end

                return true
            end,
            keyword_length = 2,
            priority = 7,
        }
    end,

    path = {
        name = "path",
        priority = 4,
        group_index = 2,
        keyword_length = 3,
        option = {
            trailing_slash = false,
            label_trailing_slash = true,
        },
    },

    snippets = {
        name = "snippets",
        keyword_length = 3,
        max_item_count = 3,
        priority = 8,
    },
}

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

    local bufnr = vim.api.nvim_get_current_buf()

    if require("helpers.file").is_bigfile(bufnr) then
        return bufs
    end

    -- Current buffer
    if cmp_get_bufnrs == "current_buf" then
        table.insert(bufs, bufnr)
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
