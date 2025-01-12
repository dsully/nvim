---@type LazySpec[]
return {
    {
        "olimorris/codecompanion.nvim",
        cmd = {
            "CodeCompanion",
            "CodeCompanionAdd",
            "CodeCompanionChat",
            "CodeCompanionActions",
        },
        config = function(_, opts)
            require("codecompanion").setup(opts)

            -- Disable some built in prompts.
            require("codecompanion.config").prompt_library["Custom Prompt"] = nil
            require("codecompanion.config").prompt_library["Explain"] = nil
            require("codecompanion.config").prompt_library["Buffer selection"] = nil

            local group = ev.group("CodeCompanionHooks")

            ev.on(ev.User, function(event)
                --
                -- Format the buffer after the inline request has completed
                if event.match == "CodeCompanionInlineFinished" then
                    require("conform").format({ bufnr = event.buf })
                end
            end, {
                group = group,
                pattern = "CodeCompanionInline*",
            })

            local status = require("plugins.ai.codecompanion.status")

            ev.on(ev.User, function(event)
                --
                if event.match == "CodeCompanionRequestStarted" then
                    status.processing = true
                elseif event.match == "CodeCompanionRequestFinished" then
                    status.processing = false
                end
            end, {
                group = group,
                pattern = "CodeCompanionRequest*",
            })
        end,
        keys = {
            --stylua: ignore start
            { "<leader>a+", function() vim.cmd.CodeCompanionChat("Add") end, mode = "v", desc = "Add" },
            { "<leader>aD", function() require("codecompanion").prompt("docstring") end, mode = "v", desc = "Docstring" },
            { "<leader>aa", function() vim.cmd.CodeCompanionActions() end, mode = { "n", "v" }, desc = "Actions" },
            { "<leader>ac", function() vim.cmd.CodeCompanionChat("Toggle") end, mode = { "n", "v" }, desc = "Chat" },
            { "<leader>ad", function() require("codecompanion").prompt("doc") end, mode = "v", desc = "Documentation" },
            { "<leader>af", function() require("codecompanion").prompt("fix") end, mode = "v", desc = "Fix Code" },
            { "<leader>al", function() require("codecompanion").prompt("lsp") end, mode = "v", desc = "LSP Diagnostics" },
            { "<leader>ao", function() require("codecompanion").prompt("optimize") end, mode = "v", desc = "Optimize" },
            { "<leader>ap", function() require("codecompanion").prompt("pr") end, desc = "Pull Request" },
            { "<leader>ar", function() require("codecompanion").prompt("refactor") end, mode = "v", desc = "Refactor" },
            { "<leader>at", function() require("codecompanion").prompt("tests") end, desc = "Generate Tests" },
            { "<leader>aw", function() require("codecompanion").prompt("workflow") end, desc = "Code Workflow" },
            --stylua: ignore end
            {
                "<leader>aq",
                function()
                    if vim.tbl_contains({ "v", "V", "x" }, vim.fn.mode()) then
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
                mode = { "n", "v", "x" },
            },
        },
        opts = {
            adapters = {
                anthropic = require("plugins.ai.codecompanion.adapters.anthropic"),
                copilot = require("plugins.ai.codecompanion.adapters.copilot"),
                deepseek = require("plugins.ai.codecompanion.adapters.deepseek"),
                gemini = require("plugins.ai.codecompanion.adapters.gemini"),
                openai = require("plugins.ai.codecompanion.adapters.openai"),
                ollama = require("plugins.ai.codecompanion.adapters.ollama"),
                openrouter = require("plugins.ai.codecompanion.adapters.openrouter"),
                qwen25 = require("plugins.ai.codecompanion.adapters.qwen"),
            },
            display = {
                chat = {
                    window = {
                        layout = "vertical", ---@type "float"|"vertical"|"horizontal"|"buffer"
                        position = "right", ---@type "left"|"right"|"top"|"bottom"
                        width = 0.4,
                    },
                    render_headers = false,
                    show_settings = false,
                },
                diff = {
                    layout = "vertical", ---@type "horizontal"|"vertical"
                    provider = "mini_diff", ---@type "default"|"mini_diff"
                },
                inline = {
                    layout = "vertical", ---@type "vertical"|"horizontal"|"buffer"
                },
            },
            prompt_library = {
                ["Generate a Commit Message"] = {
                    opts = {
                        modes = { "n" },
                    },
                },
                ["Communication"] = require("plugins.ai.codecompanion.prompts.communications"),
                ["Docstring"] = require("plugins.ai.codecompanion.prompts.docstring"),
                ["Documentation"] = require("plugins.ai.codecompanion.prompts.documentation"),
                ["Expert"] = require("plugins.ai.codecompanion.prompts.expert"),
                ["Naming"] = require("plugins.ai.codecompanion.prompts.naming"),
                ["Optimize"] = require("plugins.ai.codecompanion.prompts.optimize"),
                ["Pull Request"] = require("plugins.ai.codecompanion.prompts.pull_request"),
                ["Refactor"] = require("plugins.ai.codecompanion.prompts.refactor"),
                ["Spelling"] = require("plugins.ai.codecompanion.prompts.spelling"),
            },
            strategies = {
                agent = { adapter = "anthropic" },
                chat = {
                    adapter = "anthropic",
                    slash_commands = {
                        buffer = { opts = { provider = "fzf_lua" } },
                        file = { opts = { provider = "fzf_lua" } },
                        help = { opts = { provider = "fzf_lua" } },
                        symbols = { opts = { provider = "fzf_lua" } },
                    },
                },
                inline = {
                    adapter = "anthropic",
                },
            },
        },
    },
    {
        "folke/which-key.nvim",
        optional = true,
        opts = {
            spec = {
                { "<leader>a", group = "AI", mode = { "n", "v" } },
                { "<localleader>a", group = "AI", mode = { "n", "v" } },
            },
        },
    },
}
