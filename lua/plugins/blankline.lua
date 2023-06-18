return {
    "lukas-reineke/indent-blankline.nvim",
    ft = { "yaml" },
    init = function()
        vim.g.indent_blankline_filetype = { "yaml" }
        vim.g.indent_blankline_show_current_context = true
        vim.g.indent_blankline_show_current_context_start = true
        vim.g.indent_blankline_show_trailing_blankline_indent = true
        vim.g.indent_blankline_use_treesitter = true
        vim.g.indent_blankline_use_treesitter_scope = true
    end,
}
