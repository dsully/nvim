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
            vim.treesitter.language.register("gotmpl", "gotexttmpl")

            -- https://github.com/MeanderingProgrammer/render-markdown.nvim#vimwiki
            vim.treesitter.language.register("markdown", "vimwiki")

            vim.highlight.priorities.semantic_tokens = 100
            vim.highlight.priorities.treesitter = 125

            nvim.command("TSInstall", function(opts)
                vim.cmd(string.format("TS install%s %s", opts.bang and "!" or "", opts.args))
            end, {
                bang = true,
                desc = "Wrapper to redirect TSInstall to ts-install's 'TS install'",
                nargs = 1,
            })
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
        event = ev.LazyFile,
        opts = function()
            local root = require("lazy.core.config").options.root

            return {
                auto_install = true,
                ensure_install = defaults.treesitter.install,
                parsers = {
                    caddyfile = {
                        install_info = {
                            path = vim.fs.joinpath(root, "tree-sitter-caddyfile"),
                            files = { "src/parser.c" },
                        },
                        filetype = "caddyfile",
                        maintainers = {},
                        tier = "community",
                    },
                    ghostty = {
                        install_info = {
                            path = vim.fs.joinpath(root, "tree-sitter-ghostty"),
                            files = { "src/parser.c" },
                            generate_from_json = true,
                            queries_dir = vim.fs.joinpath(root, "tree-sitter-ghostty", "queries", "ghostty"),
                        },
                        filetype = "ghostty",
                        maintainers = {},
                        tier = "community",
                    },
                    pkl = {
                        install_info = {
                            url = "https://github.com/apple/tree-sitter-pkl",
                            files = { "src/parser.c", "src/scanner.c" },
                            queries_dir = vim.fs.joinpath(root, "pkl-neovim", "queries", "pkl"),
                            used_by = { "pcf" },
                        },
                        filetype = "pkl",
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
    { "bezhermoso/tree-sitter-ghostty", ft = "ghostty" },
    { "matthewpi/tree-sitter-caddyfile" },
    -- Only required for the tree-sitter queries.
    { "apple/pkl-neovim" },
}
