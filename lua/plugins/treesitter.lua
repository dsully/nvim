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

            vim.treesitter.language.add("htmljinja", {
                path = vim.api.nvim_get_runtime_file("parser/jinja2.so", false)[1],
                symbol_name = "jinja2",
            })

            require("helpers.file").symlink_queries("caddyfile")
            require("helpers.file").symlink_queries("ghostty")
            require("helpers.file").symlink_queries("jinja2", "jinja2")
            require("helpers.file").symlink_queries("jinja2", "htmljinja")
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
        event = ev.VeryLazy,
        opts = {
            auto_install = true,
            ensure_install = defaults.treesitter.install,
            parsers = {
                caddyfile = {
                    install_info = {
                        url = "https://github.com/matthewpi/tree-sitter-caddyfile",
                        files = { "src/parser.c" },
                        branch = "master",
                    },
                    filetype = "caddyfile",
                    maintainers = {},
                    tier = 3,
                },
                ghostty = {
                    install_info = {
                        url = "https://github.com/bezhermoso/tree-sitter-ghostty",
                        files = { "src/parser.c" },
                        branch = "main",
                    },
                    filetype = "ghostty",
                    maintainers = {},
                    tier = 3,
                },
                jinja2 = {
                    install_info = {
                        url = "https://github.com/geigerzaehler/tree-sitter-jinja2",
                        files = { "src/parser.c" },
                        branch = "main",
                    },
                    filetype = "jinja2",
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
        event = ev.LazyFile,
        opts = {},
    },
    -- Needed for queries. Right now both ghostty and jinja2 use the old .get_parsers() call to nvim-treesitter.
    { "matthewpi/tree-sitter-caddyfile" },
    { "bezhermoso/tree-sitter-ghostty", cond = false },
    { "geigerzaehler/tree-sitter-jinja2", cond = false },
}
