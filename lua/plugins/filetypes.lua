return {
    -- Log file syntax highlighting.
    { "MTDL9/vim-log-highlighting", ft = "log" },

    -- Caddy
    { "isobit/vim-caddyfile", ft = "caddyfile" },

    -- Better vim help.
    {
        "OXY2DEV/helpview.nvim",
        lazy = false,
    },

    -- Apple's PKL language.
    {
        "apple/pkl-neovim",
        build = ":TSInstall! pkl",
        event = "BufReadPre *.pkl",
    },

    -- Direnv highlighting & more.
    { "direnv/direnv.vim", ft = "direnv" },

    -- JSON Sorting
    { "2nthony/sortjson.nvim", ft = "json", opts = true },

    {
        "vuki656/package-info.nvim",
        config = function()
            local package = require("package-info")

            package.setup()

            vim.keymap.set("n", "<leader>nu", package.update, { desc = "Package: Update package on line" })
            vim.keymap.set("n", "<leader>nd", package.delete, { desc = "Package: Delete package on line" })
            vim.keymap.set("n", "<leader>ni", package.install, { desc = "Package: Install new package" })
            vim.keymap.set("n", "<leader>nv", package.change_version, { desc = "Package: Change version of package on line" })
        end,
        event = "BufRead package.json",
    },

    {
        "nvim-java/nvim-java",
        config = function(_, opts)
            require("java").setup(opts)
            require("lspconfig").jdtls.setup({
                capabilities = require("plugins.lsp.common").setup(),
            })
        end,
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-java/lua-async-await",
            "nvim-java/nvim-java-core",
            "nvim-java/nvim-java-dap",
            "nvim-java/nvim-java-refactor",
            "nvim-java/nvim-java-test",
        },
        ft = { "java" },
        opts = {
            jdk = { auto_install = false },
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        keys = {
            -- stylua: ignore
            { "<leader>um", function() vim.cmd.RenderMarkdown("toggle") end, desc = "Render Markdown", },
        },
        ft = { "markdown", "vimwiki" },
        opts = {
            file_types = { "markdown", "vimwiki" },
            code = {
                sign = false,
                width = "block",
                right_pad = 1,
            },
            heading = {
                sign = false,
                icons = {},
            },
        },
    },
}
