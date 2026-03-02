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
    {
        "https://codeberg.org/mraspaud/smellycat.nvim",
        ft = "python",
        opts = {
            debounce_ms = 500,
            smells = {
                arrow_code = { enabled = true, max_depth = 4 },
                brain_method = { enabled = true, max_lines = 50, max_branches = 10 },
                data_class = { enabled = true, min_non_dunder_methods = 1 },
                data_clumps = { enabled = true, min_clump_size = 3, min_occurrences = 2 },
                feature_envy = { enabled = true, external_call_ratio_threshold = 0.75 },
                god_object = { enabled = true, max_methods = 20, max_references = 100 },
                inappropriate_intimacy = { enabled = true, min_private_accesses = 1 },
                lazy_class = { enabled = true, min_methods = 2 },
                long_parameter_list = { enabled = true, max_params = 5 },
                message_chains = { enabled = true, max_chain_length = 3 },
                middle_man = { enabled = true, min_delegation_ratio = 0.75 },
                switch_statements = { enabled = true, min_cases = 5 },
            },
            max_concurrent_lsp_requests = 4,
        },
    },
}
