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
            { "<leader>i", vim.cmd.Inspect, desc = "Inspect Position" },
        },
        ---@type TSConfig
        opts = {
            ensure_install = {},
            ignore_install = { "unsupported" },
            install_dir = vim.g.ts_path,
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = ev.VeryLazy,
    },
    {
        "lewis6991/ts-install.nvim",
        build = ":TS update",
        cmd = "TS",
        event = ev.VeryLazy,
        dependencies = { "nvim-treesitter" },
        opts = {
            auto_install = true,
            ensure_install = defaults.treesitter.install,
            parsers = {
                caddy = {
                    install_info = {
                        url = "https://github.com/Samonitari/tree-sitter-caddy",
                        files = { "src/parser.c", "src/scanner.c" },
                        branch = "master",
                        revision = "65b60437983933d00809c8927e7d8a29ca26dfa3",
                    },
                    filetype = "caddyfile",
                    maintainers = {},
                    tier = 3,
                },
            },
        },
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
        event = ev.VeryLazy,
        opts = {},
    },
}
