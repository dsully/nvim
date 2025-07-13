---@type LazySpec[]
return {
    {
        "Davidyz/inlayhint-filler.nvim",
        ft = "python",
        keys = {
            {
                "<leader>ci",
                function()
                    require("inlayhint-filler").fill()
                end,
                desc = "Insert the inlay-hint under cursor into the buffer.",
                mode = { "n", "v" },
            },
        },
    },
    {
        "benomahony/uv.nvim",
        cmd = { "UVInit", "UVRunFile", "UVRunSelection", "UVRunFunction" },
        ft = "python",
        opts = {
            auto_activate_venv = false,
            auto_commands = true,
            notify_activate_venv = false,
            picker_integration = true,

            -- Keymaps to register (set to false to disable)
            keymaps = {
                prefix = "<leader>x", -- Main prefix for uv commands
                commands = true, -- Show uv commands menu (<leader>x)
                run_file = true, -- Run current file (<leader>xr)
                run_selection = true, -- Run selected code (<leader>xs)
                run_function = true, -- Run function (<leader>xf)
                venv = true, -- Environment management (<leader>xe)
                init = true, -- Initialize uv project (<leader>xi)
                add = true, -- Add a package (<leader>xa)
                remove = true, -- Remove a package (<leader>xd)
                sync = true, -- Sync packages (<leader>xc)
            },
            execution = {
                run_command = "uv run python",
                notify_output = true,
                notification_timeout = 10000,
            },
        },
    },
}
