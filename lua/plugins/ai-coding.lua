local model = "gpt-4-turbo-preview"

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
            vim.keymap.set("n", "<leader>cc", vim.cmd.ChatGPT, { desc = "Ask a question..." })
            vim.keymap.set({ "n", "x" }, "<leader>ci", vim.cmd.ChatGPTEditWithInstructions, { desc = "Edit with instructions" })

            for _, map in pairs({
                { key = "g", cmd = "grammar_correction", desc = "Grammar Correction" },
                { key = "d", cmd = "docstring", desc = "Add Doc-Strings" },
                { key = "T", cmd = "add_tests", desc = "Add Tests" },
                { key = "o", cmd = "optimize_code", desc = "Optimize Code" },
                { key = "s", cmd = "summarize", desc = "Summarize" },
                { key = "f", cmd = "fix_bugs", desc = "Fix Bugs" },
                { key = "x", cmd = "explain_code", desc = "Explain Code" },
                { key = "l", cmd = "code_readability_analysis", desc = "Code Readability Analysis" },
            }) do
                vim.keymap.set({ "n", "x" }, "<leader>c" .. map.key, function()
                    vim.cmd.ChatGPTRun(map.cmd)
                end, { desc = map.desc })
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
                sessions_window = { border = { style = vim.g.border } },
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
            popup_window = { border = { style = vim.g.border } },
            settings_window = { border = { style = vim.g.border } },
            system_input = { border = { style = vim.g.border } },
            system_window = { border = { style = vim.g.border } },
            welcome_message = "",
        },
    },
    {
        "zbirenbaum/copilot.lua",
        config = function(_, opts)
            for _, ft in ipairs(require("config.defaults").ai_file_types) do
                opts.filetypes[ft] = true
            end

            require("copilot").setup(opts)

            local ok, cmp = pcall(require, "cmp")

            if ok then
                -- Remove Copilot ghost text when the cmp menu is opened.
                cmp.event:on("menu_opened", function()
                    require("copilot.suggestion").dismiss()
                    vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", true)
                end)

                cmp.event:on("menu_closed", function()
                    vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", false)
                end)
            end
        end,
        event = "LazyFile",
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
        "piersolenski/wtf.nvim",
        opts = {
            openai_model_id = model,
        },
        keys = {
            -- stylua: ignore
            { "cD", mode = { "n", "x" }, function() require("wtf").ai() end, desc = "Debug diagnostic with AI", },
        },
    },
    {
        "olimorris/codecompanion.nvim",
        cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionToggle", "CodeCompanionActions", "CodeCompanionAdd" },
        config = function(_, opts)
            -- Ensure that telescope.ui is loaded.
            require("telescope")
            require("codecompanion").setup(opts)
        end,
        opts = {
            ai_settings = {
                chat = { model = model },
                inline = { model = model },
            },
            display = {
                chat = {
                    type = "buffer",
                    buf_options = {
                        buflisted = true,
                    },
                    win_options = {
                        wrap = true,
                        linebreak = true,
                    },
                },
            },
            keymaps = {
                ["<C-y>"] = "keymaps.save",
            },
            silence_notifications = true,
        },
        keys = {
            --stylua: ignore
            { "<C-a>", vim.cmd.CodeCompanionActions, mode = { "n", "x" }, desc = "Code Companion Actions" },
            { "<localleader>a", vim.cmd.CodeCompanionToggle, mode = { "n", "x" }, desc = "Code Companion Chat" },
        },
    },
}
