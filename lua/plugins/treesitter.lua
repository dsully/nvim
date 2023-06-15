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
            -- Use gcc so tree-sitter-just (and others) compile.
            require("nvim-treesitter.install").compilers = { "gcc", "clang" }

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
                    "graphql",
                    "hcl",
                    "html",
                    "htmldjango",
                    "http",
                    "ini",
                    "java",
                    "javascript",
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
                indent = { enable = true, disable = { "python" } },

                -- Use treesitter to autoclose and autorename HTML tags.
                -- https://github.com/windwp/nvim-ts-autotag
                autotag = { enable = true },

                -- https://github.com/JoosepAlviste/nvim-ts-context-commentstring
                context_commentstring = {
                    enable = true,
                    enable_autocmd = false, -- for Comment.nvim integration
                },

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

                textobjects = {
                    lsp_interop = {
                        enable = true,
                        border = vim.g.border,
                        peek_definition_code = {
                            ["<leader>cf"] = { query = "@function.outer", desc = "Peek Function Outer" },
                            ["<leader>cF"] = { query = "@class.outer", desc = "Peek Class Outer " },
                        },
                    },
                    move = {
                        enable = true,
                        goto_next_start = {
                            ["]f"] = { query = "@function.outer", desc = "Next function start." },
                        },
                        goto_previous_start = {
                            ["[f"] = { query = "@function.outer", desc = "Previous function start." },
                        },
                    },
                },

                -- https://github.com/RRethy/nvim-treesitter-textsubjects
                textsubjects = {
                    enable = true,
                    -- keymap to select the previous selection
                    prev_selection = ",",
                    -- These are all visual mode.
                    keymaps = {
                        ["."] = "textsubjects-smart",
                        ["[["] = "textsubjects-container-outer",
                        ["]]"] = "textsubjects-container-inner",
                    },
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

    { "IndianBoy42/tree-sitter-just", build = ":TSInstall just", config = true, ft = "just" },

    { "RRethy/nvim-treesitter-endwise", event = "InsertEnter" },
    { "yioneko/nvim-yati", event = "InsertEnter" },

    {
        "echasnovski/mini.ai",
        config = function()
            local spec_treesitter = require("mini.ai").gen_spec.treesitter

            require("mini.ai").setup({
                custom_textobjects = {
                    o = spec_treesitter({
                        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
                    }, {}),
                    f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
                    c = spec_treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
                },
                n_lines = 500,
            })
        end,
        dependencies = {
            {
                -- no need to load the plugin, since we only need its queries
                "nvim-treesitter/nvim-treesitter-textobjects",
                init = function()
                    require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
                end,
            },
        },
        keys = {
            { "a", mode = { "x", "o" } },
            { "i", mode = { "x", "o" } },
        },
    },

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
