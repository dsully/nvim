local e = require("helpers.event")
local model = "gpt-4o"

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
            { "<leader>cD", mode = { "n", "x" }, function() require("wtf").ai() end, desc = "Debug diagnostic with AI", },
        },
    },
    {
        "olimorris/codecompanion.nvim",
        cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionToggle", "CodeCompanionActions", "CodeCompanionAdd" },
        keys = {
            --stylua: ignore
            { "<C-a>", vim.cmd.CodeCompanionActions, mode = { "n", "x" }, desc = "Code Companion Actions" },
            { "<localleader>a", vim.cmd.CodeCompanionToggle, mode = { "n", "x" }, desc = "Code Companion Chat" },
        },
        opts = function()
            return {
                adapters = {
                    openai = require("codecompanion.adapters").use("openai", {
                        schema = {
                            model = {
                                default = model,
                            },
                        },
                    }),
                },
                display = {
                    chat = {
                        window = {
                            layout = "float",
                            height = 0.75,
                            width = 0.75,
                        },
                    },
                },
                keymaps = {
                    ["<C-y>"] = "keymaps.save",
                },
                silence_notifications = true,
            }
        end,
    },

    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "canary",
        cmd = "CopilotChat",
        opts = {
            answer_header = "  Copilot ",
            auto_insert_mode = true,
            model = model,
            question_header = "  " .. vim.env.USER .. " ",
            selection = function(source)
                local select = require("CopilotChat.select")
                return select.visual(source) or select.buffer(source)
            end,
            show_help = true,
            window = {
                width = 0.4,
            },
        },
        keys = {
            -- stylua: ignore
            { "<leader>aa", function() return require("CopilotChat").toggle() end, desc = "Toggle (CopilotChat)", mode = { "n", "v" }, },
            -- stylua: ignore
            { "<leader>ax", function() return require("CopilotChat").reset() end, desc = "Clear (CopilotChat)", mode = { "n", "v" }, },
            {
                "<leader>aq",
                function()
                    local input = vim.fn.input("Quick Chat: ")
                    if input ~= "" then
                        require("CopilotChat").ask(input)
                    end
                end,
                desc = "Quick Chat (CopilotChat)",
                mode = { "n", "v" },
            },
        },
        config = function(_, opts)
            e.on(e.BufEnter, function()
                vim.opt_local.relativenumber = false
                vim.opt_local.number = false
            end, {
                pattern = "copilot-chat",
            })

            require("CopilotChat.integrations.cmp").setup()
            require("CopilotChat").setup(opts)
        end,
    },
}
