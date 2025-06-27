---@type LazySpec[]
return {
    { "nvim-lua/plenary.nvim" },
    { "MunifTanjim/nui.nvim" },
    { "b0o/schemastore.nvim" },

    -- Log file syntax highlighting.
    { "fei6409/log-highlight.nvim", event = "BufRead *.log", opts = {} },

    -- For adding words to typos.toml
    { "vhyrro/toml-edit.lua", build = "rockspec", priority = 1000 },

    -- Color palette management.
    { "bhugovilela/palette.nvim", cmd = "Palette" },

    {
        "dsully/ignore.nvim",
        keys = {
            -- stylua: ignore
            { "<leader>di", function() require("helpers.ignore").ignore() end },
        },
        virtual = true,
    },

    {
        "maskudo/devdocs.nvim",
        cmd = "DevDocs",
        event = ev.LazyFile,
        keys = {
            {
                "<leader>ho",
                mode = "n",
                "<cmd>DevDocs get<cr>",
                desc = "Get Devdocs",
            },
            {
                "<leader>hi",
                mode = "n",
                "<cmd>DevDocs install<cr>",
                desc = "Install Devdocs",
            },
            {
                "<leader>hv",
                mode = "n",
                function()
                    local devdocs = require("devdocs")
                    local installedDocs = devdocs.GetInstalledDocs()

                    vim.ui.select(installedDocs, {}, function(selected)
                        if not selected then
                            return
                        end
                        -- prettify the filename as you wish
                        Snacks.picker.files({ cwd = devdocs.GetDocDir(selected) })
                    end)
                end,
                desc = "Get Devdocs",
            },
            {
                "<leader>hd",
                mode = "n",
                "<cmd>DevDocs delete<cr>",
                desc = "Delete Devdoc",
            },
        },
        opts = {
            ensure_installed = {
                "docker~19",
                "fish~4.0",
                "git",
                "nix",
                "python~3.11",
                "python~3.12",
                "python~3.13",
                "rust",
            },
        },
    },

    -- Better vim help.
    {
        "OXY2DEV/helpview.nvim",
        ft = { "help", "vimdoc" },
        opts = {
            preview = {
                icon_provider = "mini",
            },
        },
    },

    -- Pretty screen shots.
    {
        "mistricky/codesnap.nvim",
        build = "make",
        cmd = {
            "CodeSnap",
            "CodeSnapSave",
        },
        enabled = function()
            return vim.env.HOSTNAME ~= "zap"
        end,
        keys = {
            { "<leader>cS", "", desc = "󰹑 Screen Shots", mode = { "v" } },
            { "<leader>cSs", "<cmd>CodeSnap<cr>", mode = "v", desc = "Save selected code snapshot into clipboard" },
            { "<leader>cSS", "<cmd>CodeSnapSave<cr>", mode = "v", desc = "Save selected code snapshot in ~/Pictures" },
        },
        opts = {
            bg_theme = "dusk",
            has_breadcrumbs = true,
            save_path = vim.env.XDG_PICTURES_DIR,
            watermark = "",
        },
    },
}
