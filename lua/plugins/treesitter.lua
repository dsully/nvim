---@module "lazy.types"
---@type LazySpec[]
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = function()
            require("nvim-treesitter.install").update()
        end,
        config = function()
            -- Install the comment parser.
            if #vim.api.nvim_get_runtime_file("parser/comment.*", false) == 0 then
                require("nvim-treesitter.install").install("comment")
            end

            if pcall(vim.treesitter.start) then
                vim.o.indentexpr = 'v:lua.require("nvim-treesitter").indentexpr()'
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

                parsers.caddyfile = {
                    install_info = {
                        path = vim.fs.joinpath(root, "tree-sitter-caddyfile"),
                        files = { "src/parser.c" },
                    },
                    filetype = "caddyfile",
                    maintainers = {},
                    tier = "community",
                }

                parsers.ghostty = {
                    install_info = {
                        path = vim.fs.joinpath(root, "tree-sitter-ghostty"),
                        files = { "src/parser.c" },
                        generate_from_json = true,
                        queries_dir = vim.fs.joinpath(root, "tree-sitter-ghostty", "queries", "ghostty"),
                    },
                    filetype = "ghostty",
                    maintainers = {},
                    tier = "community",
                }

                parsers.pkl = {
                    install_info = {
                        url = "https://github.com/apple/tree-sitter-pkl",
                        files = { "src/parser.c", "src/scanner.c" },
                        queries_dir = vim.fs.joinpath(root, "pkl-neovim", "queries", "pkl"),
                        used_by = { "pcf" },
                    },
                    filetype = "pkl",
                    maintainers = {},
                    tier = "community",
                }

                parsers.pyproject = {
                    install_info = {
                        -- url = "https://github.com/dsully/tree-sitter-pyproject",
                        -- url = "~/dev/home/tree-sitter-pyproject",
                        path = "~/dev/home/tree-sitter-pyproject",
                        files = { "src/parser.c", "src/scanner.c" },
                        revision = "",
                    },
                    filetype = "pyproject",
                    maintainers = {},
                    tier = "community",
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
