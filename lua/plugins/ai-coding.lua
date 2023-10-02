return {
    {
        "jackmort/chatgpt.nvim",
        cmd = {
            "ChatGPT",
            "ChatGPTActAs",
            "ChatGPTEditWithInstructions",
            "ChatGPTRun",
        },
        config = function(_, opts)
            require("chatgpt").setup(opts)

            vim.keymap.set("n", "<leader>cc", vim.cmd.ChatGPT, { desc = "Ask a question..." })
            vim.keymap.set({ "n", "x" }, "<leader>ci", vim.cmd.ChatGPTEditWithInstructions, { desc = "Edit with instructions" })

            for _, map in pairs({
                { key = "g", cmd = "grammar_correction", desc = "Grammar Correction" },
                { key = "t", cmd = "translate", desc = "Translate" },
                { key = "k", cmd = "keywords", desc = "Keywords" },
                { key = "d", cmd = "docstring", desc = "Add Doc-Strings" },
                { key = "a", cmd = "add_tests", desc = "Add Tests" },
                { key = "o", cmd = "optimize_code", desc = "Optimize Code" },
                { key = "s", cmd = "summarize", desc = "Sumamrize" },
                { key = "f", cmd = "fix_bugs", desc = "Fix Bugs" },
                { key = "x", cmd = "explain_code", desc = "Explain Code" },
                { key = "l", cmd = "code_readability_analysis", desc = "Code Readability Analysis" },
            }) do
                vim.keymap.set("n", "<leader>c" .. map.key, function()
                    vim.cmd.ChatGPTRun(map.cmd)
                end, { desc = map.desc })
            end
        end,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
        event = "VeryLazy",
        opts = {
            answer_sign = "",
            chat = {
                sessions_window = {
                    border = {
                        style = vim.g.border,
                    },
                },
            },
            keymaps = {
                close = { "<C-c>" },
                yank_last = "<C-y>",
                scroll_up = "<C-k>",
                scroll_down = "<C-j>",
                toggle_settings = "<C-o>",
                new_session = "<C-n>",
                cycle_windows = "<Tab>",
            },
            openai_params = {
                model = "gpt-4",
            },
            popup_window = { border = { style = vim.g.border } },
            settings_window = { border = { style = vim.g.border } },
            system_input = { border = { style = vim.g.border } },
            system_window = { border = { style = vim.g.border } },
            question_sign = "",
            welcome_message = "",
        },
    },
    {
        "zbirenbaum/copilot.lua",
        config = function(_, opts)
            require("copilot").setup(opts)

            local cmp = require("cmp")
            cmp.event:on("menu_opened", function()
                vim.b.copilot_suggestion_hidden = true
            end)

            cmp.event:on("menu_closed", function()
                vim.b.copilot_suggestion_hidden = false
            end)

            -- local keys = {
            --     {
            --         "<C-a>",
            --         function()
            --             require("copilot.suggestion").accept()
            --         end,
            --         description = "Accept suggestion",
            --         mode = { "i" },
            --         opts = { silent = true },
            --     },
            --     {
            --         "<C-x>",
            --         function()
            --             require("copilot.suggestion").dismiss()
            --         end,
            --         description = "Dismiss suggestion",
            --         mode = { "i" },
            --         opts = { silent = true },
            --     },
            --     {
            --         "<C-n>",
            --         function()
            --             require("copilot.suggestion").next()
            --         end,
            --         description = "Next suggestion",
            --         mode = { "i" },
            --         opts = { silent = true },
            --     },
            -- }
        end,
        event = "InsertEnter",
        opts = {
            filetypes = {
                bash = true,
                c = true,
                cpp = true,
                fish = true,
                go = true,
                html = true,
                java = true,
                javascript = true,
                just = true,
                lua = true,
                python = true,
                rust = true,
                sh = true,
                typescript = true,
                zsh = true,
                ["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
            },
            -- Per: https://github.com/zbirenbaum/copilot-cmp#install
            -- panel = { enabled = false },
            -- suggestion = { enabled = false },

            panel = {
                enabled = true,
                auto_refresh = true,
            },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = "<M-l>",
                    accept_word = false,
                    accept_line = false,
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<Esc>",
                },
            },
        },
    },
    {
        "huggingface/llm.nvim",
        config = function(_, opts)
            require("llm").setup(opts)

            local cmp = require("cmp")

            cmp.event:on("menu_opened", function()
                require("llm.completion").suggestions_enabled = false
            end)

            cmp.event:on("menu_closed", function()
                require("llm.completion").suggestions_enabled = true
            end)
        end,
        -- event = "VeryLazy",
        init = function()
            vim.api.nvim_create_user_command("StarCoder", function()
                require("llm.completion").complete()
            end, {})
        end,
        opts = {
            api_token = vim.env.HF_TOKEN,
            -- accept_keymap = "<Left>",
            -- dismiss_keymap = "<Right>",
            accept_keymap = "<Tab>",
            dismiss_keymap = "<S-Tab>",
            model = "bigcode/starcoder",
            query_params = {
                max_new_tokens = 200,
            },
        },
    },
}
