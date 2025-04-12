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

    {
        "rachartier/tiny-glimmer.nvim",
        event = "TextYankPost",
        opts = {
            enabled = true,
            default_animation = "fade",
            refresh_interval_ms = 6,
            transparency_color = colors.bg,
            animations = {
                fade = {
                    max_duration = 250,
                    chars_for_max_duration = 10,
                },
            },
        },
    },

    -- Pretty screen shots.
    {
        "mistricky/codesnap.nvim",
        build = "make build_generator",
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
