local mode = { "n", "x" }

return {
    -- TODO: Add to WhichKey?
    --
    -- When in the chat buffer, there are number of keymaps available to you:
    --
    -- ? - Bring up the menu that lists the keymaps and commands
    -- <CR>|<C-s> - Send the buffer to the LLM
    -- <C-c> - Close the buffer
    -- q - Cancel the request from the LLM
    -- gr - Regenerate the last response from the LLM
    -- ga - Change the adapter
    -- gx - Clear the buffer's contents
    -- gx - Add a codeblock
    -- gf - To refresh the code folds in the buffer
    -- gd - Debug the chat buffer
    -- } - Move to the next chat
    -- { - Move to the previous chat
    -- ]] - Move to the next header
    -- [[ - Move to the previous header
    "olimorris/codecompanion.nvim",
    cmd = {
        "CodeCompanion",
        "CodeCompanionAdd",
        "CodeCompanionChat",
        "CodeCompanionActions",
    },
    keys = {
        --stylua: ignore start
        { "<leader>aa", vim.cmd.CodeCompanionActions, mode = mode, desc = "Code Companion Actions" },
        { "<leader>ac", function() vim.cmd.CodeCompanionChat("Toggle") end, mode = mode, desc = "Code Companion Chat" },
        { "<leader>ad", function() require("codecompanion").prompt("lsp") end, mode = mode, desc = "Debug Diagnostics" },
        { "<leader>af", function() require("codecompanion").prompt("fix") end, mode = mode, desc = "Fix Code" },
        { "<leader>ao", function() require("codecompanion").prompt("optimize") end, mode = mode, desc = "Optimize" },
        --stylua: ignore end
        {
            "<leader>aq",
            function()
                if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "x" then
                    vim.ui.input({ prompt = "CodeCompanion: " }, function(input)
                        if input then
                            vim.cmd("'<,'>CodeCompanion " .. input)
                        end
                    end)
                else
                    vim.ui.input({ prompt = "CodeCompanion: " }, function(input)
                        if input then
                            vim.cmd.CodeCompanion(input)
                        end
                    end)
                end
            end,
            desc = "Prompt (CodeCompanion)",
            mode = mode,
        },
    opts = function()
        local prompts = require("codecompanion.config").prompt_library

        prompts["Custom Prompt"] = nil
        prompts["Explain"] = nil
        prompts["Buffer selection"] = nil
        prompts["Generate a Commit Message"] = nil

        return {
            display = {
                -- chat = {
                --     window = {
                --         layout = "horizontal",
                --         height = 0.40,
                --     },
                -- },
                diff = {
                    provider = "default",
                },
            },
            prompt_library = {
                ["Optimize"] = {
                    strategy = "chat",
                    description = "Optimize the selected code",
                    opts = {
                        mapping = "<leader>ao",
                        modes = { "v" },
                        short_name = "optimize",
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
            strategies = {
                chat = { adapter = "anthropic" },
                inline = { adapter = "anthropic" },
            },
        }
    end,
}
