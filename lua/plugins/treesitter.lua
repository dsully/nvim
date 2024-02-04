return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        cmd = {
            "TSBufDisable",
            "TSBufEnable",
            "TSDisable",
            "TSEnable",
            "TSInstall",
            "TSModuleInfo",
            "TSUpdate",
            "TSUpdateSync",
        },
        ---@param opts TSConfig
        config = function(_, opts)
            local parser = require("nvim-treesitter.parsers").get_parser_configs()

            ---@type ParserInfo
            ---@diagnostic disable-next-line: inject-field
            parser.caddy = {
                install_info = {
                    url = "https://github.com/Samonitari/tree-sitter-caddy",
                    files = { "src/parser.c", "src/scanner.c" },
                    branch = "master",
                    revision = "65b60437983933d00809c8927e7d8a29ca26dfa3",
                },
                filetype = "caddyfile",
                maintainers = {},
            }

            ---@type ParserInfo
            ---@diagnostic disable-next-line: inject-field
            parser.gotmpl = {
                install_info = {
                    url = "https://github.com/ngalaiko/tree-sitter-go-template",
                    files = { "src/parser.c" },
                    revision = "45acf03891557b80a45ac1897e2cca2e8b9cf0ff",
                },
                filetype = "gotmpl",
                maintainers = {},
                used_by = { "gohtmltmpl", "gotexttmpl", "gotmpl" },
            }

            -- Map languages to my created file types.
            vim.treesitter.language.register("bash", "sh")
            vim.treesitter.language.register("ruby", "Brewfile")

            if type(opts.ensure_installed) == "table" then
                ---@type table<string, boolean>
                local added = {}

                opts.ensure_installed = vim.tbl_filter(function(lang)
                    if added[lang] then
                        return false
                    end
                    added[lang] = true
                    return true
                end, opts.ensure_installed) ---@diagnostic disable-line: param-type-mismatch
            end

            require("nvim-treesitter.configs").setup(opts)
        end,
        event = { "LazyFile", "VeryLazy" },
        init = function(plugin)
            require("lazy.core.loader").add_to_rtp(plugin)
            require("nvim-treesitter.query_predicates")
        end,
        keys = {
            { "<leader>i", vim.show_pos, desc = "Inspect Position" },
        },
        ---@type TSConfig
        ---@diagnostic disable-next-line: missing-fields
        opts = {
            ensure_installed = {
                "bash",
                "c",
                "caddy",
                "cmake",
                "comment",
                "cpp",
                "css",
                "diff",
                "dockerfile",
                "fish",
                "git_config",
                "git_rebase",
                "gitignore",
                "go",
                "gomod",
                "gotmpl",
                "graphql",
                "groovy",
                "hcl",
                "html",
                "htmldjango",
                "http",
                "ini",
                "java",
                "javascript",
                "jsdoc",
                "json",
                "jsonc",
                "kdl",
                "kotlin",
                "lua",
                "luadoc",
                "luap",
                "make",
                "markdown",
                "markdown_inline",
                "mermaid",
                "passwd",
                "proto",
                "python",
                "query",
                "regex",
                "requirements",
                "rst",
                "ruby",
                "ssh_config",
                "strace",
                "swift",
                "teal",
                "textproto",
                "ron",
                "rust",
                "toml",
                "tsx",
                "typescript",
                "vim",
                "vimdoc",
                "yaml",
                "xml",
            },
            autotag = { enable = true },
            highlight = { enable = true },
            indent = { enable = true },
            matchup = { enable = true },
            query_linter = {
                enable = true,
                use_virtual_text = true,
                lint_events = { "BufWrite", "CursorHold" },
            },
        },
    },
    {
        -- Better % matching.
        "andymass/vim-matchup",
        init = function()
            vim.o.matchpairs = "(:),{:},[:],<:>"

            -- Don't recognize anything in comments
            vim.g.matchup_delim_noskips = 2

            vim.g.matchup_matchparen_deferred = 1
            vim.g.matchup_matchparen_offscreen = { method = "status_manual" }

            -- Wrong matching for HTML: https://github.com/andymass/vim-matchup/issues/19
            vim.g.matchup_matchpref = { html = { nolists = 1 } }
        end,
        event = "LazyFile",
    },
    {
        -- Use treesitter to auto-close and auto-rename HTML tags.
        "windwp/nvim-ts-autotag",
        ft = { "html", "javascript", "markdown", "xml" },
        opts = {},
    },

    -- f-string manipulation.
    { "chrisgrieser/nvim-puppeteer", ft = "python" },

    -- Build treesitter queries.
    {
        "ziontee113/query-secretary",
        keys = {
            {
                "<leader>fQ",
                function()
                    require("query-secretary").query_window_initiate()
                end,
                desc = "Find TS Query",
            },
        },
    },
    {
        -- "shellRaining/hlchunk.nvim",
        "dsully/hlchunk.nvim",
        event = { "LspAttach" },
        opts = {
            blank = {
                enable = false,
            },
            chunk = {
                chars = {
                    horizontal_line = "─",
                    vertical_line = "│",
                    left_top = "┌",
                    left_bottom = "└",
                    right_arrow = "─",
                },
                style = "#81a1c1",
                use_treesitter = true,
            },
            indent = {
                enable = false,
            },
        },
    },
}
