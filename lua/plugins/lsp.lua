---@type LazySpec[]
return {
    {
        "neovim/nvim-lspconfig",
        event = ev.VeryLazy,
        config = function()
            vim.lsp.log.set_level(vim.lsp.log.levels.WARN)

            vim.diagnostic.config({
                float = {
                    focusable = true,
                    header = { "" },
                    severity_sort = true,
                    spacing = 2,
                    source = true,
                },
                severity_sort = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = defaults.icons.diagnostics.error,
                        [vim.diagnostic.severity.WARN] = defaults.icons.diagnostics.warn,
                        [vim.diagnostic.severity.INFO] = defaults.icons.diagnostics.info,
                        [vim.diagnostic.severity.HINT] = defaults.icons.diagnostics.hint,
                    },
                },
                underline = true,
                update_in_insert = false, -- https://www.reddit.com/r/neovim/comments/pfk209/nvimlsp_too_fast/
            })

            ---@type table<string, string[]|boolean>?
            local kind_filter = {
                default = {
                    "Class",
                    "Constructor",
                    "Enum",
                    "Field",
                    "Function",
                    "Interface",
                    "Method",
                    "Module",
                    "Namespace",
                    "Package",
                    "Property",
                    "Struct",
                    "Trait",
                },
                markdown = false,
                help = false,
                -- you can specify a different filter for each filetype
                lua = {
                    "Class",
                    "Constructor",
                    "Enum",
                    "Field",
                    "Function",
                    "Interface",
                    "Method",
                    "Module",
                    "Namespace",
                    -- "Package", -- remove package since luals uses it for control flow structures
                    "Property",
                    "Struct",
                    "Trait",
                },
            }

            ev.on_load("which-key.nvim", function()
                vim.schedule(function()
                    -- stylua: ignore
                    require("which-key").add({
                        { "]d", require("lib.lsp").diagnostic_goto(true), desc = "Next Diagnostic" },
                        { "[d", require("lib.lsp").diagnostic_goto(false), desc = "Prev Diagnostic" },
                        { "]e", require("lib.lsp").diagnostic_goto(true, vim.diagnostic.severity.ERROR), desc = "Next Error" },
                        { "[e", require("lib.lsp").diagnostic_goto(false, vim.diagnostic.severity.ERROR), desc = "Prev Error" },
                        { "]w", require("lib.lsp").diagnostic_goto(true, vim.diagnostic.severity.WARN), desc = "Next Warning" },
                        { "[w", require("lib.lsp").diagnostic_goto(false, vim.diagnostic.severity.WARN), desc = "Prev Warning" },

                        { "<C-S>", vim.lsp.buf.signature_help, desc = "Signature Help", mode = "i", icon = "󰠗 " },
                        { "<leader>l", group = "LSP", icon = " " },
                        { "<leader>lc", vim.cmd.LspCapabilities, desc = "LSP Capabilities", icon = " " },
                        { "<leader>li", nvim.lsp.info, desc = "LSP Info", icon = " " },
                        { "<leader>ll", vim.cmd.LspLog, desc = "LSP Log", icon = " " },
                        { "<leader>lr", vim.cmd.LspRestartBuffer, desc = "LSP Restart", icon = " " },
                        { "<leader>ls", vim.cmd.LspStop, desc = "LSP Stop", icon = " " },
                        { "<leader>xr", vim.diagnostic.reset, desc = "Reset", icon = " " },
                        { "<leader>xs", vim.diagnostic.open_float, desc = "Show", icon = "󰙨" },
                        { "gra", nvim.lsp.code_action, desc = "Actions", icon = "󰅯 " },
                        { "grn", vim.lsp.buf.rename, desc = "Rename", icon = " " },
                        { "grq", nvim.lsp.apply_quickfix, desc = "Apply Quick Fix", icon = "󱖑 " },

                        -- Snacks pickers
                        { "gD", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition" },
                        { "gO", function() Snacks.picker.lsp_symbols({ filter = kind_filter }) end, desc = "References" },
                        { "gd", function() Snacks.picker.lsp_definitions({ unique_lines = true }) end, desc = "Goto Definition" },
                        { "gi", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
                        { "grf", function() Snacks.rename.rename_file() end, desc = "Rename File", icon = " ", },
                        { "grr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },

                        { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
                        { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
                    } --[[@as wk.Spec]], { notify = false })
                end)
            end)

            -- Handle dynamic registration.
            --
            -- https://github.com/neovim/neovim/issues/24229
            local register_capability = vim.lsp.handlers["client/registerCapability"]

            ---@param res lsp.RegistrationParams
            ---@param ctx lsp.HandlerContext
            vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
                local client_id = ctx.client_id
                local client = vim.lsp.get_client_by_id(client_id)

                if client ~= nil then
                    for buffer in pairs(client.attached_buffers) do
                        --
                        ev.emit(ev.User, {
                            pattern = ev.LspDynamicCapability,
                            data = { client_id = client.id, buffer = buffer },
                        })
                    end
                end

                return register_capability(err, res, ctx)
            end

            nvim.lsp.on_attach(nvim.lsp.validate_client)
            nvim.lsp.on_dynamic_capability(nvim.lsp.validate_client)
            nvim.lsp.on_dynamic_capability(function() end)
            nvim.lsp.commands()

            vim.lsp.on_type_formatting.enable()

            nvim.lsp.on_supports_method("textDocument/documentColor", function(_, buffer)
                vim.lsp.document_color.enable(true, buffer)

                keys.map("grc", vim.lsp.document_color.color_presentation, "vim.lsp.document_color.color_presentation()")

                Snacks.toggle({
                    name = "Color",
                    get = function()
                        return vim.lsp.document_color.is_enabled()
                    end,
                    set = function(state)
                        vim.lsp.document_color.enable(not state)
                    end,
                }):map("<space>tc")
            end)

            nvim.lsp.on_supports_method("textDocument/inlayHint", function()
                vim.lsp.inlay_hint.enable(false)
            end)

            nvim.lsp.on_supports_method("textDocument/semanticTokens/full", function()
                Snacks.toggle({
                    name = "Semantic Tokens",
                    get = function()
                        return vim.lsp.semantic_tokens.is_enabled()
                    end,
                    set = function(state)
                        vim.lsp.semantic_tokens.enable(not state)
                    end,
                }):map("<space>tS")
            end)

            nvim.lsp.on_supports_method("textDocument/codeLens", function()
                --
                ev.on({ ev.BufEnter, ev.CursorHold, ev.InsertLeave }, function()
                    if vim.g.codelens then
                        vim.lsp.codelens.refresh({ bufnr = 0 })
                    end
                end, {
                    group = ev.group("vim.lsp.codelens.refresh", true),
                })

                Snacks.toggle({
                    name = "Code Lens",
                    get = function()
                        return vim.g.codelens
                    end,
                    set = function(state)
                        vim.g.codelens = state

                        if state == true then
                            vim.lsp.codelens.refresh()
                        else
                            vim.lsp.codelens.clear()
                        end
                    end,
                }):map("<space>tL")
            end)

            local capabilities = nil

            if pcall(require, "blink.cmp") then
                capabilities = require("blink.cmp").get_lsp_capabilities({
                    textDocument = {
                        onTypeFormatting = {
                            dynamicRegistration = false,
                        },
                    },
                    workspace = {
                        didChangeWatchedFiles = {
                            dynamicRegistration = true,
                        },
                    },
                })
            end

            -- Set defaults
            vim.lsp.config("*", {
                capabilities = capabilities,
                root_markers = { ".git" },
            } --[[@as vim.lsp.Config]])

            local configured = {
                "bashls",
                "basedpyright",
                -- "codebook",
                "config-lsp",
                "dockerls",
                "emmylua_ls",
                "fish-ls",
                "gopls",
                "harper_ls",
                "helm_ls",
                "jinja_lsp",
                "jsonls",
                "just-lsp",
                "lemminx",
                "nil_ls",
                "nixd",
                "pkl",
                "pyrefly",
                "ruff",
                "sourcekit",
                "superhtml",
                "systemd_ls",
                "tombi",
                "ts_query_ls",
                "tsgo",
                "ty",
                "yamlls",
                "zls",
            }

            vim.iter(configured):each(vim.schedule_wrap(function(server_name)
                -- if disabled[server_name] then
                --     return
                -- end
                vim.lsp.enable(server_name)
            end))
        end,
    },
    {
        "oribarilan/lensline.nvim",
        cond = false,
        event = ev.LspAttach,
        opts = {
            -- Profile configuration (first profile used as default)
            profiles = {
                {
                    name = "default",
                    providers = { -- Array format: order determines display sequence
                        {
                            name = "usages",
                            enabled = true, -- enable usages provider by default (replaces references)
                            include = { "refs" }, -- refs-only setup to match references provider behavior
                            breakdown = true, -- false = aggregate count, true = breakdown by type
                            show_zero = true, -- show zero counts when LSP supports the capability
                            labels = {
                                refs = "refs",
                                impls = "impls",
                                defs = "defs",
                                usages = "usages",
                            },
                            icon_for_single = "󰌹 ", -- icon when only one attribute or aggregate display
                            inner_separator = ", ", -- separator between breakdown items
                        },
                        {
                            name = "last_author",
                            enabled = true, -- enabled by default with caching optimization
                            cache_max_files = 50, -- maximum number of files to cache blame data for (default: 50)
                        },
                        -- additional built-in or custom providers can be added here
                    },
                    style = {
                        separator = " • ", -- separator between all lens attributes
                        highlight = "Comment", -- highlight group for lens text
                        prefix = "┃ ", -- prefix before lens content
                        placement = "above", -- "above" | "inline" - where to render lenses (consider prefix = "" for inline)
                        use_nerdfont = true, -- enable nerd font icons in built-in providers
                        render = "all", -- "all" | "focused" (only active window's focused function)
                    },
                },
                -- You can define additional profiles here and switch between them at runtime
                -- , {
                --   name = "minimal",
                --   providers = { { name = "diagnostics", enabled = true } },
                --   style = { render = "focused" }
                -- }
            },
            -- global settings (apply to all profiles)
            limits = {
                -- exclude = {
                -- file patterns that lensline will not process for lenses
                -- see config.lua for extensive list of default patterns
                -- },
                exclude_append = {}, -- additional patterns to append to exclude list (empty by default)
                exclude_gitignored = true, -- respect .gitignore by not processing ignored files
                max_lines = 1000, -- process only first N lines of large files
                max_lenses = 70, -- skip rendering if too many lenses generated
            },
            debounce_ms = 500, -- unified debounce delay for all providers
            focused_debounce_ms = 150, -- debounce delay for focus tracking in focused mode
            silence_lsp = true, -- suppress noisy LSP log messages (e.g., Pyright reference spam)
            debug_mode = false, -- enable debug output for development, see CONTRIBUTE.md
        },
    },
}
