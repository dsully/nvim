---@type LazySpec[]
return {
    { "nvim-lua/plenary.nvim" },
    { "MunifTanjim/nui.nvim" },
    { "b0o/schemastore.nvim" },

    -- Log file syntax highlighting.
    { "fei6409/log-highlight.nvim", event = "BufRead *.log", opts = {} },

    {
        "minigian/juan-logs.nvim",
        build = function(plugin)
            if plugin then
                local path = plugin.dir .. "/build.lua"
                if vim.uv.fs_access(path, "R") == 1 then
                    dofile(path)
                end
            end
        end,
        lazy = false,
    },

    -- For adding words to typos.toml
    { "faithanalog/toml.lua", lazy = false, priority = 1000 },

    {
        "CameronDixon0/hex-reader.nvim",
        keys = {
            -- stylua: ignore
            { "<leader>hx", function() require("hex_reader").toggle() end, desc = "Toggle hex reader." },
        },
        opts = true,
    },

    {
        "dsully/ignore.nvim",
        keys = {
            -- stylua: ignore
            { "<leader>di", function() require("lib.ignore").ignore() end },
        },
        virtual = true,
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
    {
        "mistweaverco/snap.nvim",
        cmd = "Snap",
        enabled = function()
            return vim.env.HOSTNAME ~= "zap"
        end,
        ---@type SnapUserConfig
        opts = {
            filename_pattern = "snap.nvim.%t",
            font_settings = {
                size = 16,
                line_height = 1.0,
                default = {
                    name = "Monaspace Neon",
                    file = nil,
                },
                bold = {
                    name = "Monaspace Neon",
                    file = nil,
                },
                italic = {
                    name = "Monaspace Neon",
                    file = nil,
                },
                bold_italic = {
                    name = "Monaspace Neon",
                    file = nil,
                },
            },
            output_dir = vim.fs.abspath("~/Library/Mobile Documents/com~apple~CloudDocs/Screenshots"),
            template = "macos",
        },
    },
}
