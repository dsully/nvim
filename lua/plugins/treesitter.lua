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

            -- Python requirements.txt
            parser.requirements = {
                install_info = {
                    url = "https://github.com/otherJL0/tree-sitter-requirements",
                    files = { "src/parser.c" },
                    branch = "main",
                    revision = "515679d20b30173320c9672efc9347d1b5519fd5",
                },
                filetype = "requirements",
            }

            parser.xml = {
                install_info = {
                    url = "https://github.com/Trivernis/tree-sitter-xml",
                    -- https://github.com/lucascool12/tree-sitter-xml
                    files = { "src/parser.c" },
                    generate_requires_npm = true,
                    branch = "main",
                    revision = "3ef1d1a92ba91445c5b4bf50a300bb61e9c9ae8a",
                },
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
                    "swift",
                    "toml",
                    "tsx",
                    "typescript",
                    "vim",
                    "vimdoc",
                    "yaml",
                    "xml",
                },

                highlight = { enable = true },

                -- Let nvim-yati do indentation.
                indent = { enable = true, disable = { "lua", "python" } },

                -- Use treesitter to auto-close and auto-rename HTML tags.
                -- https://github.com/windwp/nvim-ts-autotag
                autotag = { enable = true },

                -- https://github.com/RRethy/nvim-treesitter-endwise
                endwise = { enable = true },

                lsp_interop = {
                    enable = false,
                },

                matchup = {
                    enable = true,
                },

                query_linter = {
                    enable = true,
                    use_virtual_text = true,
                    lint_events = { "BufWrite", "CursorHold" },
                },

                -- https://github.com/yioneko/nvim-yati
                yati = {
                    enable = true,
                    suppress_conflict_warning = true,
                },
            })

            vim.keymap.set("n", "<leader>i", vim.show_pos, { desc = "Inspect Position" })
        end,
        event = { "BufReadPost", "BufNewFile" },
    },

    { "RRethy/nvim-treesitter-endwise", event = "InsertEnter" },
    { "yioneko/nvim-yati", event = "InsertEnter" },

    -- Use treesitter to auto-close and auto-rename HTML tags.
    { "windwp/nvim-ts-autotag", ft = { "html", "javascript", "markdown", "xml" }, opts = {} },

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
