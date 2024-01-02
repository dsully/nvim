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

            -- Map languages to my created file types.
            vim.treesitter.language.register("bash", "sh")
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
                    "ron",
                    "rst",
                    "ruby",
                    "rust",
                    "ssh_config",
                    "strace",
                    "swift",
                    "teal",
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

                indent = { enable = true },

                query_linter = {
                    enable = true,
                    use_virtual_text = true,
                    lint_events = { "BufWrite", "CursorHold" },
                },
            })

            vim.keymap.set("n", "<leader>i", vim.show_pos, { desc = "Inspect Position" })
        end,
        event = vim.g.defaults.lazyfile,
        init = function(plugin)
            -- From Lazyvim: Add nvim-treesitter queries to the rtp and it's custom query predicates early
            -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
            -- no longer trigger the **nvim-treeitter** module to be loaded in time.
            -- Luckily, the only thins that those plugins need are the custom queries, which we make available during startup.
            require("lazy.core.loader").add_to_rtp(plugin)
            require("nvim-treesitter.query_predicates")
        end,
    },

    -- Better % matching.
    {
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
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            opts = function(_, opts)
                opts.matchup = { enable = true }
            end,
        },
        event = vim.g.defaults.lazyfile,
    },

    {
        "RRethy/nvim-treesitter-endwise",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            opts = function(_, opts)
                opts.endwise = { enable = true }
            end,
        },
        event = vim.g.defaults.lazyfile,
    },

    -- Use treesitter to auto-close and auto-rename HTML tags.
    {
        "windwp/nvim-ts-autotag",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            opts = function(_, opts)
                opts.autotag = { enable = true }
            end,
        },
        ft = { "html", "javascript", "markdown", "xml" },
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
        "shellRaining/hlchunk.nvim",
        config = function()
            -- Don't enable for non-treesitter types
            local exclude_filetypes = {
                ["bzl"] = true,
                ["gitcommit"] = true,
                ["json5"] = true,
                ["jsonc"] = true,
                ["just"] = true,
                ["text"] = true,
            }

            for _, ft in ipairs(require("config.defaults").ignored.file_types) do
                exclude_filetypes[ft] = true
            end

            require("hlchunk").setup({
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
                    exclude_filetypes = exclude_filetypes,
                    style = "#81a1c1",
                },
                indent = {
                    enable = false,
                },
            })
        end,
        event = { "LspAttach" },
    },
}
