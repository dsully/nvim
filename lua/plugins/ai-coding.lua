local mode = { "n", "x" }
local model = "gpt-4o-2024-08-06"

return {
    {
        "jackmort/chatgpt.nvim",
        cmd = {
            "ChatGPT",
            "ChatGPTActAs",
            "ChatGPTEditWithInstructions",
            "ChatGPTRun",
        },
        init = function()
            keys.map("<leader>aq", vim.cmd.ChatGPT, "Ask a question...")
            keys.map("<leader>ai", vim.cmd.ChatGPTEditWithInstructions, "Edit with instructions", mode)

            for _, map in pairs({
                { key = "A", cmd = "code_readability_analysis", desc = "Analyze Readability" },
                { key = "D", cmd = "docstring", desc = "Add Docstrings" },
                { key = "T", cmd = "add_tests", desc = "Add Tests" },
                { key = "f", cmd = "fix_bugs", desc = "Fix Bugs" },
                { key = "g", cmd = "grammar_correction", desc = "Grammar Correction" },
                { key = "o", cmd = "optimize_code", desc = "Optimize Code" },
                { key = "s", cmd = "summarize", desc = "Summarize Code" },
                { key = "x", cmd = "explain_code", desc = "Explain Code" },
            }) do
                keys.map("<leader>a" .. map.key, function()
                    vim.cmd.ChatGPTRun(map.cmd)
                end, map.desc, mode)
            end
        end,
        opts = {
            chat = {
                answer_sign = "",
                keymaps = {
                    close = { "<C-c>", "<Esc>" },
                    yank_last = "<C-y>",
                    scroll_up = "<C-k>",
                    scroll_down = "<C-j>",
                    toggle_settings = "<C-o>",
                    new_session = "<C-n>",
                    cycle_windows = "<Tab>",
                },
                question_sign = "",
                sessions_window = { border = { style = defaults.ui.border.name } },
            },
            edit_with_instructions = {
                diff = true,
                keymaps = {
                    accept = "<C-y>",
                    close = "<C-c>",
                    cycle_windows = "<Tab>",
                    new_session = "<C-n>",
                    toggle_diff = "<C-d>",
                    toggle_settings = "<C-o>",
                    use_output_as_input = "<C-i>",
                },
            },
            openai_params = {
                model = model,
                max_tokens = 600,
            },
            openai_edit_params = {
                model = model,
                max_tokens = 600,
            },
            popup_input = {
                submit = "<C-Enter>",
            },
            popup_window = { border = { style = defaults.ui.border.name } },
            settings_window = { border = { style = defaults.ui.border.name } },
            system_input = { border = { style = defaults.ui.border.name } },
            system_window = { border = { style = defaults.ui.border.name } },
            welcome_message = "",
        },
    },
    {
        "zbirenbaum/copilot.lua",
        config = function(_, opts)
            for _, ft in ipairs(defaults.ai_file_types) do
                opts.filetypes[ft] = true
            end

            require("copilot").setup(opts)

            -- Disable for now.
            -- local ok, cmp = pcall(require, "cmp")
            local ok = false

            if ok then
                -- Remove Copilot ghost text when the cmp menu is opened.
                require("cmp").event:on("menu_opened", function()
                    require("copilot.suggestion").dismiss()
                    vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", true)
                end)

                require("cmp").event:on("menu_closed", function()
                    vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", false)
                end)
            end
        end,
        event = ev.LazyFile,
        opts = {
            filetypes = {
                ["*"] = false, -- Disable for all other filetypes and ignore default `filetypes`
            },
            -- Per: https://github.com/zbirenbaum/copilot-cmp#install
            -- panel = { enabled = false },
            -- suggestion = { enabled = false },
            panel = {
                enabled = false,
                auto_refresh = true,
            },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = "<C-y>",
                    accept_word = false,
                    accept_line = false,
                    next = "<C-n>",
                    prev = "<C-p>",
                    dismiss = "<Esc>",
                },
            },
        },
    },
    {
        "olimorris/codecompanion.nvim",
        cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionToggle", "CodeCompanionActions" },
        keys = {
            --stylua: ignore
            { "<leader>aa", vim.cmd.CodeCompanionActions, mode = mode, desc = "Code Companion Actions" },
            { "<leader>aC", vim.cmd.CodeCompanionToggle, mode = mode, desc = "Code Companion Chat" },
            {
                "<leader>ad",
                function()
                    vim.cmd.CodeCompanion("lsp")
                end,
                mode = mode,
                desc = "Debug Diagnostics",
            },
        },
        opts = {
            display = {
                chat = {
                    window = {
                        layout = "horizontal",
                        height = 0.40,
                    },
                },
            },
        },
    },
}
