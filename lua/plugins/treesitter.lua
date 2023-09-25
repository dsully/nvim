-- Treesitter and extensions.
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
            "TSUpdateSync",
        },
        config = function()
            local parser = require("nvim-treesitter.parsers").get_parser_configs()

            parser.caddy = {
                install_info = {
                    url = "https://github.com/Samonitari/tree-sitter-caddy",
                    files = { "src/parser.c", "src/scanner.c" },
                    branch = "master",
                    revision = "65b60437983933d00809c8927e7d8a29ca26dfa3",
                },
                filetype = "caddyfile",
            }

            parser.gotmpl = {
                install_info = {
                    url = "https://github.com/ngalaiko/tree-sitter-go-template",
                    files = { "src/parser.c" },
                    revision = "45acf03891557b80a45ac1897e2cca2e8b9cf0ff",
                },
                filetype = "gotmpl",
                used_by = { "gohtmltmpl", "gotexttmpl", "gotmpl" },
            }

            -- Treat Brewfiles as Ruby for syntax highlighting.
            vim.treesitter.language.register("ruby", "Brewfile")
            vim.treesitter.language.register("bash", "sh")

            require("nvim-treesitter.configs").setup({

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
                    "ron",
                    "rst",
                    "ruby",
                    "rust",
                    "ssh_config",
                    "strace",
                    "swift",
                    "textproto",
                    "toml",
                    "tsx",
                    "typescript",
                    "vim",
                    "vimdoc",
                    "yaml",
                    "xml",
                },

                highlight = { enable = true },

                query_linter = {
                    enable = true,
                    use_virtual_text = true,
                    lint_events = { "BufWrite", "CursorHold" },
                },
            })

            vim.keymap.set("n", "<leader>i", vim.show_pos, { desc = "Inspect Position" })
        end,
        event = { "BufReadPost", "BufNewFile" },
    },

    {
        "RRethy/nvim-treesitter-endwise",
        config = function()
            require("nvim-treesitter.configs").setup({
                endwise = {
                    enable = true,
                },
            })
        end,
        event = "InsertEnter",
    },

    {
        "yioneko/nvim-yati",
        config = function()
            require("nvim-treesitter.configs").setup({
                indent = {
                    enable = true,
                    disable = { "lua", "python" },
                },
                yati = {
                    enable = true,
                    suppress_conflict_warning = true,
                },
            })
        end,
        event = "InsertEnter",
    },

    -- Use treesitter to auto-close and auto-rename HTML tags.
    {
        "windwp/nvim-ts-autotag",
        config = function()
            require("nvim-treesitter.configs").setup({
                autotag = {
                    enable = true,
                    filetypes = { "html", "javascript", "markdown", "xml" },
                },
            })
        end,
        event = "InsertEnter",
    },

    -- f-string manipulation.
    { "chrisgrieser/nvim-puppeteer", lazy = false }, -- plugin lazy-loads itself

    -- Build treesitter queries.
    {
        "ziontee113/query-secretary",
        keys = {
            {
                "<leader>fq",
                function()
                    require("query-secretary").query_window_initiate()
                end,
                desc = "Find TS Query",
            },
        },
    },
}
