---@type LazySpec[]
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        init = function()
            -- ts-install handles commands and installs.
            vim.g.loaded_nvim_treesitter = 1

            -- Map languages to my created file types.
            vim.treesitter.language.register("bash", "direnv")
            vim.treesitter.language.register("ruby", "brewfile")

            -- https://github.com/MeanderingProgrammer/render-markdown.nvim#vimwiki
            vim.treesitter.language.register("markdown", "vimwiki")

            vim.highlight.priorities.semantic_tokens = 100
            vim.highlight.priorities.treesitter = 125
        end,
        lazy = false,
        keys = {
            -- stylua: ignore
            { "<leader>i", function() vim.cmd.Inspect() end, desc = "Inspect Position" },
        },
        opts = {
            ensure_install = {},
            ignore_install = { "unsupported" },
            install_dir = vim.g.ts_path,
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = ev.LazyFile,
    },
    {
        "lewis6991/ts-install.nvim",
        build = ":TS update!",
        cmd = "TS",
        commit = "b5b7d602",
        event = ev.VeryLazy,
        opts = function()
            local root = require("lazy.core.config").options.root

            return {
                auto_install = true,
                ensure_install = defaults.treesitter.install,
                parsers = {
                    caddyfile = {
                        install_info = {
                            url = "https://github.com/matthewpi/tree-sitter-caddyfile",
                            files = { "src/parser.c" },
                            branch = "master",
                            queries_dir = vim.fs.joinpath(root, "tree-sitter-caddyfile", "queries"),
                        },
                        filetype = "caddyfile",
                        maintainers = {},
                        tier = "community",
                    },
                    ghostty = {
                        install_info = {
                            url = "https://github.com/bezhermoso/tree-sitter-ghostty",
                            files = { "src/parser.c" },
                            branch = "main",
                            generate_from_json = true,
                            queries_dir = vim.fs.joinpath(root, "tree-sitter-ghostty", "queries", "ghostty"),
                        },
                        filetype = "ghostty",
                        maintainers = {},
                        tier = "community",
                    },
                    jinja2 = {
                        install_info = {
                            url = "https://github.com/dsully/tree-sitter-jinja2",
                            files = { "src/parser.c" },
                            branch = "dsully/nvim-treesitter-1.x",
                            -- branch = "main",
                            queries_dir = vim.fs.joinpath(root, "tree-sitter-jinja2", "queries", "jinja2"),
                        },
                        filetype = "jinja2",
                        maintainers = {},
                        tier = "community",
                    },
                },
            }
        end,
    },
    {
        "maxbol/treesorter.nvim",
        cmd = "TSort",
        opts = {},
    },
    {
        "dsully/treesitter-jump.nvim",
        dev = true,
        keys = {
            -- stylua: ignore
            { "%", function() require("treesitter-jump").jump() end },
        },
        opts = {},
    },
    {
        "folke/ts-comments.nvim",
        event = ev.LazyFile,
        opts = {},
    },
    { "matthewpi/tree-sitter-caddyfile" },
    { "bezhermoso/tree-sitter-ghostty", ft = "ghostty" },
    { "dsully/tree-sitter-jinja2", branch = "dsully/nvim-treesitter-1.x" },
}
