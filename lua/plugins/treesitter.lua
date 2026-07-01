local parsers = {
    "bash",
    "caddy",
    "css",
    "diff",
    "editorconfig",
    "fish",
    "git_config",
    "gitignore",
    "git_rebase",
    "go",
    "html",
    "ini",
    "javascript",
    "json",
    "just",
    "nix",
    "objc",
    "pkl",
    "python",
    "regex",
    "rust",
    "swift",
    "toml",
    "typescript",
    "yaml",
}

-- https://github.com/gbprod/tree-sitter-gitcommit/issues/88
if vim.env.HOSTNAME ~= "zap" then
    table.insert(parsers, "gitcommit")
end

---@type zpack.Spec[]
return {
    {
        "romus204/tree-sitter-manager.nvim",
        config = function()
            require("tree-sitter-manager").setup({
                auto_install = true,
                border = defaults.ui.border.name,
                ensure_installed = parsers,
                min_width = 120,
                noauto_install = {
                    "lua",
                    "markdown",
                    "markdown_inline",
                    "query",
                    "vim",
                    "vimdoc",
                },
            })

            -- vim.highlight.priorities.semantic_tokens = 100
            -- vim.highlight.priorities.treesitter = 125
        end,
        lazy = false,
        keys = {
            { "<leader>i", vim.cmd.Inspect, desc = "Inspect Position" },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = ev.LazyFile,
        init = function()
            vim.g.no_plugin_maps = true
        end,
    },
    {
        "dsully/treesitter-jump.nvim",
        config = function()
            keys.map("%", require("treesitter-jump").jump)
        end,
        ft = {
            "lua",
            "python",
        },
    },
    {
        "folke/ts-comments.nvim",
        event = ev.LazyFile,
        opts = {},
    },
}
