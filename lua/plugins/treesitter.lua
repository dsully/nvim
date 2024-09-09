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
        config = function(_, opts)
            local parser = require("nvim-treesitter.parsers").get_parser_configs()

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

            -- Map languages to my created file types.
            vim.treesitter.language.register("bash", "sh")
            vim.treesitter.language.register("ruby", "brewfile")

            -- https://github.com/MeanderingProgrammer/render-markdown.nvim#vimwiki
            vim.treesitter.language.register("markdown", "vimwiki")

            if type(opts.ensure_installed) == "table" then
                ---@type table<string, boolean>
                local added = {}

                opts.ensure_installed = vim.iter(opts.ensure_installed):filter(function(lang)
                    if added[lang] then
                        return false
                    end
                    added[lang] = true
                    return true
                end)
            end

            require("nvim-treesitter.configs").setup(opts)
        end,
        event = { ev.LazyFile },
        init = function(plugin)
            require("lazy.core.loader").add_to_rtp(plugin)
            require("nvim-treesitter.query_predicates")
        end,
        keys = {
            { "<leader>i", vim.show_pos, desc = "Inspect Position" },
        },
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
                "editorconfig",
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
                "just",
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
                "zig",
            },
            highlight = {
                ---@param _lang string
                ---@param bufnr number
                disable = function(_lang, bufnr)
                    return require("helpers.file").is_large_file(bufnr)
                end,
                enable = true,
            },
            indent = { enable = true },
            matchup = { enable = true },
            query_linter = {
                enable = true,
                use_virtual_text = true,
                lint_events = { ev.BufWrite, ev.CursorHold },
            },
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
        end,
    },
    {
        -- Better Around/Inside text-objects
        --
        -- Examples:
        --  - va)  - Visually select [A]round [)]parenthesis
        --  - yinq - Yank Inside [N]ext [']quote
        --  - ci'  - Change Inside [']quote
        --
        -- https://www.reddit.com/r/neovim/comments/10qmicv/help_understanding_miniai_custom_textobjects/
        "echasnovski/mini.ai",
        event = ev.VeryLazy,
        opts = function()
            local ai = require("mini.ai")
            local mini = require("helpers.mini")

            local opts = {
                n_lines = 500,
                custom_textobjects = {
                    o = ai.gen_spec.treesitter({ -- code block
                        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
                    }),

                    -- 'vaF' to select around function definition.
                    -- 'diF' to delete inside function definition.
                    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
                    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class

                    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
                    d = { "%f[%d]%d+" }, -- digits
                    e = { -- Word with case
                        { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
                        "^().*()$",
                    },

                    i = mini.ai_indent, -- indent
                    g = mini.ai_buffer, -- buffer

                    u = ai.gen_spec.function_call(), -- u for "Usage"
                    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
                },
            }

            ev.on_load("which-key.nvim", function()
                vim.schedule(function()
                    mini.ai_whichkey(opts)
                end)
            end)

            return opts
        end,
    },
    {
        -- Build treesitter queries.
        "ziontee113/query-secretary",
        -- stylua: ignore
        keys = { { "<leader>fQ", function() require("query-secretary").query_window_initiate() end, desc = "Find TS Query" } },
    },
}
