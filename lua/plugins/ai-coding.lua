local mode = { "n", "x" }
-- local model = "gpt-4o-2024-08-06"

return {
    {
        "zbirenbaum/copilot.lua",
        config = function(_, opts)
            for _, ft in ipairs(defaults.ai_file_types) do
                opts.filetypes[ft] = true
            end

            -- Remove Copilot ghost text when the cmp menu is opened.
            ev.on_load("cmp", function()
                vim.schedule(function()
                    local cmp = require("cmp")

                    cmp.event:on("menu_opened", function()
                        require("copilot.suggestion").dismiss()
                        vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", true)
                    end)

                    cmp.event:on("menu_closed", function()
                        vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", false)
                    end)
                end)
            end)

            require("copilot").setup(opts)
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
        cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
        --stylua: ignore start
        keys = {
            { "<leader>aa", vim.cmd.CodeCompanionActions, mode = mode, desc = "Code Companion Actions" },
            { "<leader>ac", vim.cmd.CodeCompanionToggle, mode = mode, desc = "Code Companion Chat" },
            { "<leader>ad", function() vim.cmd.CodeCompanion("/lsp") end, mode = mode, desc = "Debug Diagnostics" },
            { "<leader>af", function() vim.cmd.CodeCompanion("/fix") end, mode = mode, desc = "Fix Code" },
            { "<leader>ao", function() vim.cmd.CodeCompanion("/optimize") end, mode = mode, desc = "Optimize" },
        },
        --stylua: ignore end
        opts = function()
            local prompts = require("codecompanion.config").prompt_library

            prompts["Custom Prompt"] = nil
            prompts["Explain"] = nil
            prompts["Buffer selection"] = nil
            prompts["Generate a Commit Message"] = nil

            return {
                prompt_library = {
                    ["Optimize"] = {
                        strategy = "chat",
                        description = "Optimize the selected code",
                        opts = {
                            mapping = "<localleader>ao",
                            modes = { "v" },
                            slash_cmd = "optimize",
                            auto_submit = true,
                            stop_context_insertion = true,
                            user_prompt = false,
                        },
                        prompts = {
                            {
                                role = "system",
                                content = function(context)
                                    return "I want you to act as a senior "
                                        .. context.filetype
                                        .. " developer. I will ask you specific questions and I want you to return concise explanations and codeblock examples."
                                end,
                                opts = {
                                    visible = false,
                                },
                            },
                            {
                                role = "user",
                                contains_code = true,
                                content = function(context)
                                    local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                                    return "Optimize the following code:\n\n```" .. context.filetype .. "\n" .. text .. "\n```\n\n"
                                end,
                            },
                        },
                    },
                },
                display = {
                    chat = {
                        window = {
                            layout = "horizontal",
                            height = 0.40,
                        },
                    },
                },
            }
        end,
    },
}
