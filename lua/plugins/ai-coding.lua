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
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
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
                model = "gpt-4-turbo-preview",
                max_tokens = 600,
            },
            openai_edit_params = {
                model = "gpt-4-turbo-preview",
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
                cmp.event:on("menu_opened", function()
                    vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", true)
                end)

                cmp.event:on("menu_closed", function()
                    vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", false)
                end)
            end
        end,
        event = "InsertEnter",
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
        "robitx/gp.nvim",
        build = function()
            vim.uv.fs_mkdir(vim.fn.stdpath("data") .. "/gp", 511)
        end,
        cmd = {
            "GpChatNew",
            "GpChatToggle",
            "GpContext",
            "GpNextAgent",
            "GpStop",
        },
        opts = {},
    },
    {
        "huggingface/llm.nvim",
        cmd = {
            "LLMSuggestion",
            "LLMToggleAutoSuggest",
        },
        config = function(_, opts)
            require("llm").setup(opts)

            local ok, cmp = pcall(require, "cmp")

            if ok then
                cmp.event:on("menu_opened", function()
                    require("llm.completion").suggestions_enabled = false
                end)

                cmp.event:on("menu_closed", function()
                    require("llm.completion").suggestions_enabled = true
                end)
            end
        end,
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
            enable_suggestions_on_files = require("config.defaults").ai_file_types,
            model = "bigcode/starcoder",
            query_params = {
                max_new_tokens = 200,
            },
        },
    },
    {
        "Bryley/neoai.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
        },
        cmd = {
            "NeoAI",
            "NeoAIOpen",
            "NeoAIClose",
            "NeoAIToggle",
            "NeoAIContext",
            "NeoAIContextOpen",
            "NeoAIContextClose",
            "NeoAIInject",
            "NeoAIInjectCode",
            "NeoAIInjectContext",
            "NeoAIInjectContextCode",
        },
        keys = {
            { "<leader>as", desc = "Summarize text" },
            { "<leader>ag", desc = "Generate commit message." },
        },
        opts = {
            models = {
                {
                    name = "openai",
                    model = "gpt-4-turbo-preview",
                },
            },
        },
    },
}
