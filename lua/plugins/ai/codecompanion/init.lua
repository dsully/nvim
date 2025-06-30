---@type LazySpec[]
return {
    {
        vim.env.CODECOMPANION_REPO or "olimorris/codecompanion.nvim",
        cmd = {
            "CodeCompanion",
            "CodeCompanionAdd",
            "CodeCompanionChat",
            "CodeCompanionActions",
        },
        config = function(_, opts)
            --
            -- Enable agentic tools without confirmation prompts.
            vim.g.codecompanion_auto_tool_mode = true

            require("codecompanion").setup(opts)

            -- Disable some built in prompts.
            require("codecompanion.config").prompt_library["Custom Prompt"] = nil
            require("codecompanion.config").prompt_library["Explain"] = nil

            local group = ev.group("CodeCompanionHooks")

            -- Format the buffer after the inline request has completed
            ev.on(ev.User, function(event)
                require("conform").format({ bufnr = event.buf })
            end, {
                group = group,
                pattern = "CodeCompanionInlineFinished",
            })

            ev.on(ev.User, function(event)
                vim.treesitter.start(event.data.bufnr, "markdown")
            end, {
                group = group,
                pattern = "CodeCompanionChatCreated",
            })

            ev.on_load("noice.nvim", function()
                require("plugins.ai.codecompanion.progress").setup()
            end)
        end,
        keys = {
            --stylua: ignore start
            -- { "<leader>a+", function() vim.cmd.CodeCompanionChat("Add") end, mode = "v", desc = "Add" },
            { "<leader>aD", function() require("codecompanion").prompt("docstring") end, mode = "v", desc = "Docstring" },
            { "<leader>aa", function() require("codecompanion").actions() end, mode = { "n", "v" }, desc = "Actions" },
            { "<leader>ac", function() require("codecompanion").toggle() end, mode = { "n", "v" }, desc = "Chat" },
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
                        ---@diagnostic disable-next-line: param-type-not-match
                        vim.ui.input({ prompt = "CodeCompanion: " }, function(input)
                            if input then
                                vim.cmd("'<,'>CodeCompanion " .. input)
                            end
                        end)
                    else
                        ---@diagnostic disable-next-line: param-type-not-match
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
        opts = function()
            local adapter = vim.env.CODECOMPANION_ADAPTER or "anthropic"

            return {
                display = {
                    action_palette = {
                        provider = "default",
                    },
                    chat = {
                        icons = {
                            tool_success = "󰸞",
                        },
                        intro_message = "",
                        window = {
                            layout = "vertical", ---@type "float"|"vertical"|"horizontal"|"buffer"
                            position = "right", ---@type "left"|"right"|"top"|"bottom"
                            width = 0.4,
                        },
                    },
                    diff = {
                        layout = "vertical", ---@type "horizontal"|"vertical"
                        provider = "mini_diff", ---@type "default"|"mini_diff"
                    },
                    inline = {
                        layout = "vertical", ---@type "vertical"|"horizontal"|"buffer"
                    },
                },
                extensions = {
                    history = {
                        enabled = true,
                        auto_generate_title = true,
                        auto_save = false,
                        chat_filter = function(chat_data)
                            local seven_days_ago = os.time() - (7 * 24 * 60 * 60)

                            return (chat_data.updated_at >= seven_days_ago) and (chat_data.cwd == vim.fn.getcwd())
                        end,
                        continue_last_chat = false,
                        delete_on_clearing_chat = false,
                        keymap = "gh",
                        picker = "snacks",
                        save_chat_keymap = "sc",
                    },
                    vectorcode = {
                        opts = {
                            add_tool = true,
                        },
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
                    agent = {
                        adapter = adapter,
                    },
                    chat = {
                        adapter = adapter,
                        slash_commands = {
                            buffer = { opts = { provider = "snacks" } },
                            file = { opts = { provider = "snacks" } },
                            help = { opts = { provider = "snacks" } },
                            symbols = { opts = { provider = "snacks" } },
                        },
                    },
                    inline = {
                        adapter = adapter,
                    },
                },
            }
        end,
    },
    {
        "ravitemer/codecompanion-history.nvim",
    },
    {
        -- Index and search code in your repositories
        "Davidyz/VectorCode",
        build = "uv tool install --upgrade vectorcode",
        version = "*",
    },
    {
        "folke/which-key.nvim",
        optional = true,
        opts = {
            spec = {
                { "<leader>a", group = "AI", mode = { "n", "v" } },
            },
        },
    },
}
