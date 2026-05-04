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
            { "<leader>aa", function() require("codecompanion").actions({}) end, mode = { "n", "v" }, desc = "Actions" },
            { "<leader>ac", function() require("codecompanion").toggle() end, mode = { "n", "v" }, desc = "Chat" },
            { "<leader>ad", function() require("codecompanion").prompt("doc") end, mode = "v", desc = "Documentation" },
            { "<leader>af", function() require("codecompanion").prompt("fix") end, mode = "v", desc = "Fix Code" },
            { "<leader>al", function() require("codecompanion").prompt("lspx") end, mode = "v", desc = "LSP Diagnostics" },
            { "<leader>ao", function() require("codecompanion").prompt("optimize") end, mode = "v", desc = "Optimize" },
            { "<leader>ap", function() require("codecompanion").prompt("pr") end, desc = "Pull Request" },
            { "<leader>ar", function() require("codecompanion").prompt("refactor") end, mode = "v", desc = "Refactor" },
            { "<leader>at", function() require("codecompanion").prompt("tests") end, desc = "Generate Tests" },
            { "<leader>aw", function() require("codecompanion").prompt("workflow") end, desc = "Code Workflow" },
            --stylua: ignore end
            {
                "<leader>aq",
                function()
                    if vim.tbl_contains({ "v", "V", "x" }, vim.api.nvim_get_mode().mode) then
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
            local adapter_name = vim.env.CODECOMPANION_ADAPTER or "codex"
            local model_name = vim.env.CODECOMPANION_MODEL or "gpt-5.5"

            ---@type CodeCompanion.Config
            return {
                adapters = {
                    acp = {
                        opts = {
                            show_presets = true,
                            show_model_choices = true,
                        },
                        claude_code = function()
                            return require("codecompanion.adapters").extend("claude_code", {
                                defaults = {
                                    mcpServers = "inherit_from_config",
                                },
                                env = {
                                    CLAUDE_CODE_OAUTH_TOKEN = "cmd:op read op://Services/Anthropic/oauth --no-newline",
                                },
                            })
                        end,
                        codex = function()
                            return require("codecompanion.adapters").extend("codex", {
                                defaults = {
                                    auth_method = "chatgpt", -- "openai-api-key"|"codex-api-key"|"chatgpt"
                                    mcpServers = "inherit_from_config",
                                    session_config_options = {
                                        model = "gpt-5.5",
                                    },
                                },
                            })
                        end,
                        gemini = function()
                            return require("codecompanion.adapters").extend("gemini_cli", {
                                defaults = {
                                    auth_method = "gemini-api-key", -- One of: "gemini-api-key" | "oauth-personal" | | "vertex-ai"
                                },
                                env = {
                                    GEMINI_API_KEY = "GEMINI_API_KEY",
                                },
                            })
                        end,
                        opencode = function()
                            return require("codecompanion.adapters").extend("opencode", {
                                defaults = {
                                    mcpServers = "inherit_from_config",
                                },
                                commands = {
                                    default = { -- this will use your opencode/opencode.json setting
                                        "opencode",
                                        "acp",
                                    },
                                },
                            })
                        end,
                    },
                    http = {
                        opts = {
                            show_presets = true,
                            show_model_choices = true,
                        },
                        anthropic = function()
                            return require("codecompanion.adapters").extend("anthropic", {
                                schema = {
                                    extended_thinking = {
                                        default = false,
                                    },
                                },
                            })
                        end,
                        gemini = function()
                            return require("codecompanion.adapters").extend("gemini", {
                                env = {
                                    api_key = "GEMINI_API_KEY",
                                },
                            })
                        end,
                        openai = function()
                            return require("codecompanion.adapters").extend("openai", {
                                env = {
                                    api_key = "OPENAI_API_KEY",
                                },
                            })
                        end,
                        openai_responses = function()
                            return require("codecompanion.adapters").extend("openai_responses", {
                                env = {
                                    api_key = "OPENAI_API_KEY",
                                },
                            })
                        end,
                    },
                },
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
                    vectorcode = {
                        opts = {
                            add_tool = true,
                        },
                    },
                },
                rules = {
                    opts = {
                        chat = { enabled = true },
                    },
                },
                prompt_library = {
                    ["Generate a Commit Message"] = {
                        opts = {
                            modes = { "n" },
                        },
                    },
                    ["Communication"] = require("plugins.ai.codecompanion.prompts.communications"),
                    ["Diagnose Errors"] = {
                        strategy = "workflow",
                        description = "Explain LSP diagnostics with source code context",
                        opts = {
                            alias = "lspx",
                        },
                        prompts = {
                            {
                                {
                                    content = function(context)
                                        return string.format("You are an expert coder...The programming language is %s.", context.filetype)
                                    end,
                                    opts = { visible = false },
                                    role = "system",
                                },
                                {
                                    content = "Please explain the following LSP diagnostics and suggest fixes:\n\n#{lsp}",
                                    opts = { auto_submit = true },
                                    role = "user",
                                },
                            },
                        },
                    },
                    ["Docstring"] = require("plugins.ai.codecompanion.prompts.docstring"),
                    ["Documentation"] = require("plugins.ai.codecompanion.prompts.documentation"),
                    ["Expert"] = require("plugins.ai.codecompanion.prompts.expert"),
                    ["Naming"] = require("plugins.ai.codecompanion.prompts.naming"),
                    ["Optimize"] = require("plugins.ai.codecompanion.prompts.optimize"),
                    ["Pull Request"] = require("plugins.ai.codecompanion.prompts.pull_request"),
                    ["Refactor"] = require("plugins.ai.codecompanion.prompts.refactor"),
                    ["Spelling"] = require("plugins.ai.codecompanion.prompts.spelling"),
                },
                interactions = {
                    agent = {
                        adapter = adapter_name,
                        model = model_name,
                    },
                    chat = {
                        adapter = adapter_name,
                        keymaps = {
                            clear = {
                                modes = { n = "gX" },
                                description = "Clear chat",
                            },
                        },
                        model = model_name,
                        slash_commands = {
                            buffer = { opts = { provider = "snacks" } },
                            file = { opts = { provider = "snacks" } },
                            help = { opts = { provider = "snacks" } },
                            symbols = { opts = { provider = "snacks" } },
                        },
                    },
                    inline = {
                        adapter = adapter_name,
                        model = model_name,
                    },
                },
            }
        end,
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
