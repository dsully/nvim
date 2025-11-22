---@type LazySpec[]
return {
    {
        ---@module "nvim-treesitter"
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        init = function()
            local languages = {
                "bash",
                "css",
                "diff",
                "editorconfig",
                "fish",
                "git_config",
                "git_rebase",
                "gitcommit",
                "gitignore",
                "go",
                "helm",
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
            }

            local isnt_installed = function(lang)
                return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
            end

            local to_install = vim.tbl_filter(isnt_installed, languages)

            if #to_install > 0 then
                require("nvim-treesitter").install(to_install)
            end

            local filetypes = {}

            for _, lang in ipairs(languages) do
                for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
                    table.insert(filetypes, ft)
                end
            end

            ev.on(ev.FileType, function(event)
                vim.treesitter.start(event.buf)
            end, {
                pattern = filetypes,
            })
        end,
        lazy = false,
        keys = {
            -- stylua: ignore
            { "<leader>i", function() vim.cmd.Inspect() end, desc = "Inspect Position" },
        },
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
        -- Broken right now on nightly / interaction with snacks indent scope.
        "calops/hmts.nvim",
        cond = false,
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
    {
        "Hdoc1509/gh-actions.nvim",
        config = function()
            require("gh-actions.tree-sitter").setup()
            require("nvim-treesitter").install("gh_actions_expressions")
        end,
        ft = "yaml.github",
    },
}
