---@module "lazy.types"
---@type LazySpec[]
return {
    {
        ---@module "nvim-treesitter"
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        config = function()
            -- Install some basics.

            ---@type string[]
            local essential = {
                "bash",
                "css",
                "html",
                "javascript",
                "latex",
                "norg",
                "regex",
                "scss",
                "svelte",
                "tsx",
                "typst",
                "vue",
            }

            for _, lang in ipairs(essential) do
                if #vim.api.nvim_get_runtime_file(string.format("parser/%s.*", lang), false) == 0 then
                    require("nvim-treesitter").install(lang)
                end
            end

            if pcall(vim.treesitter.start) then
                vim.bo.indentexpr = 'v:lua.require("nvim-treesitter").indentexpr()'
            end
        end,
        init = function()
            -- Map languages to my created file types.
            vim.treesitter.language.register("bash", "direnv")
            vim.treesitter.language.register("ruby", "brewfile")
            vim.treesitter.language.register("gotmpl", "gotexttmpl")

            -- https://github.com/MeanderingProgrammer/render-markdown.nvim#vimwiki
            vim.treesitter.language.register("markdown", "vimwiki")

            vim.hl.priorities.semantic_tokens = 100
            vim.hl.priorities.treesitter = 125

            -- Not sure if there is better place for this.
            ev.on(ev.BufEnter, function()
                --
                if #vim.api.nvim_get_runtime_file(string.format("parser/%s.*", vim.bo.filetype), false) == 0 then
                    require("nvim-treesitter").install(vim.bo.filetype)
                end
            end)

            ev.on(ev.User, function()
                local root = require("lazy.core.config").options.root
                local parsers = require("nvim-treesitter.parsers")

                ---@type ParserInfo
                parsers.caddyfile = {
                    install_info = {
                        path = vim.fs.joinpath(root, "tree-sitter-caddyfile"),
                        files = { "src/parser.c" },
                    } --[[@as InstallInfo]],
                    filetype = "caddyfile",
                    maintainers = {},
                    tier = 3,
                }

                ---@type ParserInfo
                parsers.ghostty = {
                    install_info = {
                        path = vim.fs.joinpath(root, "tree-sitter-ghostty"),
                        files = { "src/parser.c" },
                        generate_from_json = true,
                        queries_dir = vim.fs.joinpath(root, "tree-sitter-ghostty", "queries", "ghostty"),
                    } --[[@as InstallInfo]],
                    filetype = "ghostty",
                    maintainers = {},
                    tier = 3,
                }

                ---@type ParserInfo
                parsers.pkl = {
                    install_info = {
                        url = "https://github.com/apple/tree-sitter-pkl",
                        files = { "src/parser.c", "src/scanner.c" },
                        queries_dir = vim.fs.joinpath(root, "pkl-neovim", "queries", "pkl"),
                        used_by = { "pcf" },
                    } --[[@as InstallInfo]],
                    filetype = "pkl",
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
    { "bezhermoso/tree-sitter-ghostty", ft = "ghostty" },
    { "matthewpi/tree-sitter-caddyfile" },
    -- Only required for the tree-sitter queries.
    { "apple/pkl-neovim" },
}
