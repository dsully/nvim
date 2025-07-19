---@type LazySpec[]
return {
    {
        ---@module "nvim-treesitter"
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({
                "bash",
                "css",
                "diff",
                "editorconfig",
                "fish",
                "ghostty",
                "git_config",
                "gitcommit",
                "gitignore",
                "go",
                "html",
                "javascript",
                "json",
                "jsonc",
                "just",
                "lua",
                "markdown",
                "markdown_inline",
                "nix",
                "pkl",
                "python",
                "query",
                "regex",
                "rust",
                "toml",
                "typescript",
                "vim",
                "vimdoc",
                "vimwiki",
                "yaml",
            })
            require("nvim-treesitter").update()
        end,

        init = function()
            local config = {
                highlight = {
                    skip = {
                        "bigfile",
                    },
                },
                indent = {
                    skip = {
                        "javascript",
                        "markdown",
                        "typescript",
                    },
                },
                languages = {
                    bash = { "direnv" },
                    ruby = { "brewfile" },
                    gotmpl = { "gotexttmpl" },
                    -- https://github.com/MeanderingProgrammer/render-markdown.nvim#vimwiki
                    markdown = { "vimwiki" },
                },
            }

            -- Map languages to my created file types.
            for lang, filetypes in pairs(config.languages) do
                vim.treesitter.language.register(lang, filetypes)
            end

            vim.hl.priorities.semantic_tokens = 100
            vim.hl.priorities.treesitter = 125

            -- https://github.com/neovim/neovim/issues/32660
            vim.g._ts_force_sync_parsing = true

            -- How to address https://github.com/nvim-treesitter/nvim-treesitter/issues/7881#issuecomment-2907762259 ?
            ev.on(ev.FileType, function(ctx)
                local filetype = ctx.match

                -- Skip bigfile, etc.
                if vim.list_contains(config.highlight.skip, filetype) then
                    return
                end

                local treesitter = require("nvim-treesitter")
                local available = treesitter.get_available()
                local language = vim.treesitter.language.get_lang(filetype)

                if vim.list_contains(available, language) then
                    --
                    treesitter.install(language):await(function()
                        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

                        if not vim.list_contains(config.indent.skip, filetype) then
                            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        end

                        pcall(vim.treesitter.start)
                    end)
                end
            end)

            ev.on(ev.User, function()
                local root = require("lazy.core.config").options.root
                local parsers = require("nvim-treesitter.parsers")

                ---@type ParserInfo
                parsers.ghostty = {
                    install_info = {
                        path = vim.fs.joinpath(root, "tree-sitter-ghostty"),
                        files = { "src/parser.c" },
                        generate_from_json = true,
                        queries = vim.fs.joinpath("queries", "ghostty"),
                    } --[[@as InstallInfo]],
                    filetype = "ghostty",
                    maintainers = {},
                    tier = 3,
                }

                ---@type ParserInfo
                parsers.pyproject = {
                    install_info = {
                        -- url = "https://github.com/dsully/tree-sitter-pyproject",
                        path = vim.fs.abspath("~/dev/home/tree-sitter-pyproject"),
                        files = { "src/parser.c", "src/scanner.c" },
                        revision = "",
                    } --[[@as InstallInfo]],
                    filetype = "pyproject",
                    maintainers = {},
                    tier = 3,
                }

                -- vim.treesitter.language.add("pyproject")
                -- vim.treesitter.language.register("toml", "pyproject")
            end, { pattern = "TSUpdate" })
        end,
        lazy = false,
        keys = {
            -- stylua: ignore
            { "<leader>i", function() vim.cmd.Inspect() end, desc = "Inspect Position" },
        },
        priority = 500,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = ev.LazyFile,
    },
    {
        "maxbol/treesorter.nvim",
        cmd = "TSort",
        opts = {},
    },
    {
        "calops/hmts.nvim",
        ft = "nix",
    },
    {
        "dsully/treesitter-jump.nvim",
        config = function()
            keys.map("%", require("treesitter-jump").jump)
        end,
        dev = false,
        ft = {
            "lua",
            "python",
        },
    },
    {
        "folke/ts-comments.nvim",
        event = ev.LazyFile,
        opts = {},
    },

    -- Only required for the tree-sitter queries.
    { "bezhermoso/tree-sitter-ghostty" },
}
