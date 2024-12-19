return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        config = function(_, opts)
            local parsers = require("nvim-treesitter.parsers")

            ---@diagnostic disable-next-line: inject-field
            parsers.caddy = {
                install_info = {
                    url = "https://github.com/Samonitari/tree-sitter-caddy",
                    files = { "src/parser.c", "src/scanner.c" },
                    branch = "master",
                    revision = "65b60437983933d00809c8927e7d8a29ca26dfa3",
                },
                filetype = "caddyfile",
                maintainers = {},
                tier = 3,
            }

            -- Map languages to my created file types.
            vim.treesitter.language.register("bash", "direnv")
            vim.treesitter.language.register("ruby", "brewfile")

            -- https://github.com/MeanderingProgrammer/render-markdown.nvim#vimwiki
            vim.treesitter.language.register("markdown", "vimwiki")

            vim.highlight.priorities.semantic_tokens = 100
            vim.highlight.priorities.treesitter = 125

            require("nvim-treesitter-textobjects")
            require("nvim-treesitter").setup(opts)
        end,
        lazy = false,
        init = function()
            -- ts-install handles commands and installs.
            vim.g.loaded_nvim_treesitter = 1
        end,
        keys = {
            { "<bs>", desc = "Decrement Selection", mode = "x" },
            { "<c-space>", desc = "Increment Selection" },
            { "<leader>i", vim.show_pos, desc = "Inspect Position" },
        },
        opts = {
            matchup = {
                enable = true,
            },
            query_linter = {
                enable = true,
                use_virtual_text = true,
                lint_events = { ev.BufWrite, ev.CursorHold },
            },
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
        init = function()
            ev.on(ev.FileType, function(args)
                pcall(vim.treesitter.start, args.buf)
            end, {
                desc = "Start treesitter highlighting",
            })
        end,
        lazy = false,
        opts = {
            auto_install = true,
            ensure_install = defaults.treesitter.install,
        },
    },
    {
        -- Better % matching.
        "andymass/vim-matchup",
        event = ev.LazyFile,
        init = function()
            vim.o.matchpairs = "(:),{:},[:],<:>"

            -- Don't recognize anything in comments
            vim.g.matchup_delim_noskips = 2

            vim.g.matchup_matchparen_deferred = 1
            vim.g.matchup_matchparen_offscreen = { method = "status_manual" }

            hl.apply({
                { MatchBackground = { link = "ColorColumn" } },
                { MatchParen = { bg = colors.gray.base, fg = colors.cyan.bright } },
                { MatchParenCur = { link = "MatchParen" } },
                { MatchWord = { link = "MatchParen" } },
            })
        end,
    },
    {
        "folke/ts-comments.nvim",
        event = ev.VeryLazy,
        opts = {},
    },
}
