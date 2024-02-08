return {
    {
        "neovim/nvim-lspconfig",
        cmd = {
            "LspInfo",
            "LspLog",
            "LspRestart",
            "LspStop",
        },
        ---@param opts PluginLspOpts
        config = function(_, opts)
            require("lspconfig.ui.windows").default_options.border = vim.g.border
            require("plugins.lsp.handlers").setup()

            vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

            local capabilities = require("plugins.lsp.common").setup()
            local handlers = {}

            if vim.g.os == "Darwin" then
                require("lspconfig").sourcekit.setup({
                    capabilities = capabilities,
                    filetypes = { "objective-c", "objective-cpp", "swift" }, -- Handle Swift. Let clangd handle C/C++
                    settings = {},
                })
            end

            for name, handler in pairs(opts.servers) do
                handlers[name] = function()
                    require("lspconfig")[name].setup(vim.tbl_deep_extend("force", { capabilities = capabilities }, handler))
                end
            end

            require("mason-lspconfig").setup({
                automatic_installation = true,
                ensure_installed = vim.tbl_keys(handlers),
                handlers = handlers,
            })
        end,
        dependencies = {
            { "b0o/schemastore.nvim", version = false },
            {
                "folke/neodev.nvim",
                dependencies = {
                    { "folke/neoconf.nvim", cmd = "Neoconf", opts = true },
                },
                opts = true,
            },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
        },
        event = "LazyFile",
        init = function()
            vim.lsp.set_log_level(vim.log.levels.ERROR)

            -- De-duplicate diagnostics, in particular from rust-analyzer/rustc
            vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(function(_, result, ...)
                --
                ---@type table<string, boolean>>
                local seen = {}

                ---@param diagnostic lsp.Diagnostic
                result.diagnostics = vim.iter.filter(function(diagnostic)
                    local key = string.format("%s:%s", diagnostic.code, diagnostic.range.start.line)

                    if not seen[key] then
                        seen[key] = true
                        return true
                    end

                    return false
                end, result.diagnostics)

                vim.lsp.diagnostic.on_publish_diagnostics(_, result, ...)
            end, {})

            vim.api.nvim_create_user_command("LspCapabilities", function()
                ---@type lsp.Client[]
                local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
                local lines = {}

                for i, client in pairs(clients) do
                    table.insert(lines, client.name:upper() .. ": ")
                    table.insert(lines, "")

                    for s in vim.inspect(client.server_capabilities):gmatch("[^\r\n]+") do
                        table.insert(lines, s)
                    end

                    if i < #clients then
                        table.insert(lines, "")
                    end
                end

                require("helpers.float").open(lines)
            end, { desc = "Show LSP Capabilities" })
        end,
        keys = {
            { "<leader>lc", vim.cmd.LspCapabilities, desc = "  LSP Capabilities" },
            { "<leader>li", vim.cmd.LspInfo, desc = "  LSP Info" },
            { "<leader>ll", vim.cmd.LspLog, desc = " LSP Log" },
            { "<leader>lr", vim.cmd.LspRestart, desc = "  LSP Restart" },
            { "<leader>ls", vim.cmd.LspStop, desc = " LSP Stop" },
        },
        opts = function()
            local defaults = require("config.defaults")

            ---@class PluginLspOpts
            local opts = {
                ---@type vim.diagnostic.Opts
                diagnostics = {
                    float = {
                        border = vim.g.border,
                        focusable = true,
                        -- header = { " Issues:" },
                        header = { "" },
                        -- max_height = math.min(math.floor(vim.o.lines * 0.3), 30),
                        -- max_width = math.min(math.floor(vim.o.columns * 0.7), 100),
                        severity_sort = true,
                        spacing = 2,
                        source = "if_many",
                        suffix = function(diag)
                            local text = ""

                            if package.loaded["rulebook"] then
                                text = require("rulebook").hasDocs(diag) and "  " or ""
                            end

                            -- suffix, highlight group. Defaults to NormalText
                            return text, ""
                        end,
                    },
                    underline = true,
                    signs = {
                        text = {
                            [vim.diagnostic.severity.ERROR] = defaults.icons.error,
                            [vim.diagnostic.severity.WARN] = defaults.icons.warn,
                            [vim.diagnostic.severity.INFO] = defaults.icons.info,
                            [vim.diagnostic.severity.HINT] = defaults.icons.hint,
                        },
                    },
                    severity_sort = true,
                    update_in_insert = false, -- https://www.reddit.com/r/neovim/comments/pfk209/nvimlsp_too_fast/
                },
                servers = {
                    bashls = {},
                    biome = {
                        single_file_support = true,
                    },
                    bufls = {},
                    bzl = {},
                    cmake = {},
                    cssls = {},
                    dockerls = {},
                    esbonio = {}, -- RestructuredText
                    gradle_ls = {},
                    graphql = {},
                    html = {},
                    jedi_language_server = {},
                    kotlin_language_server = {},
                    lemminx = {}, -- XML
                    lua_ls = {},
                    marksman = {}, -- Markdown
                    terraformls = {},
                    typos_lsp = {},
                    clangd = {
                        filetypes = { "c", "cpp", "cuda" }, -- Let SourceKit handle objective-c and objective-cpp.
                        init_options = {
                            clangdFileStatus = true,
                            completeUnimported = true,
                            usePlaceholders = true,
                            semanticHighlighting = true,
                        },
                        on_attach = function()
                            -- https://github.com/p00f/clangd_extensions.nvim
                            require("clangd_extensions").setup()

                            local inlay_hints = require("clangd_extensions.inlay_hints")

                            inlay_hints.setup_autocmd()
                            inlay_hints.set_inlay_hints()
                            inlay_hints.toggle_inlay_hints()
                        end,
                        root_dir = function(fname)
                            return require("lspconfig.util").root_pattern("Makefile", "configure.in", "meson.build", "build.ninja")(fname)
                                or require("lspconfig.util").find_git_ancestor(fname)
                        end,
                    },
                    gopls = {
                        filetypes = { "go", "gomod", "gowork" }, -- Don't attach for gotmpl.
                        init_options = {
                            usePlaceholders = true,
                        },
                        ---@param client lsp.Client
                        on_attach = function(client)
                            -- As of v0.11.0, gopls does not send a Semantic Token legend (in a
                            -- client/registerCapability message) unless the client supports dynamic
                            -- registration. Neovim's LSP client does not support dynamic registration
                            -- for semantic tokens, so we need to declare those server_capabilities
                            -- ourselves for the time being.
                            -- Ref. https://github.com/golang/go/issues/54531
                            --
                            if not not client.server_capabilities.semanticTokensProvider then
                                local semantic = client.config.capabilities.textDocument.semanticTokens

                                if semantic then
                                    client.server_capabilities.semanticTokensProvider = {
                                        full = true,
                                        legend = {
                                            tokenModifiers = semantic.tokenModifiers,
                                            tokenTypes = semantic.tokenTypes,
                                        },
                                        range = true,
                                    }
                                end
                            end
                        end,
                    },
                    jsonls = {
                        on_new_config = function(c)
                            c.settings.json.schemas = vim.tbl_deep_extend("force", c.settings.json.schemas or {}, require("schemastore").json.schemas())
                        end,
                    },
                    ruff_lsp = {
                        commands = {
                            RuffAutoFix = {
                                function()
                                    vim.lsp.buf.code_action({ context = { only = { "source.fixAll.ruff" } }, apply = true })
                                end,
                                description = "Ruff: Auto Fix",
                            },

                            RuffOrganizeImports = {
                                function()
                                    vim.lsp.buf.code_action({ context = { only = { "source.organizeImports.ruff" } }, apply = true })
                                end,
                                description = "Ruff: Organize Imports",
                            },
                        },
                        filetypes = { "python", "toml.pyproject" },
                        ---@param client lsp.Client
                        on_attach = function(client)
                            client.server_capabilities.hoverProvider = false
                        end,
                        ---@param new_config lspconfig.Config
                        on_new_config = function(new_config)
                            local ruff = require("helpers.ruff")

                            -- We need to check our probe directories because they may have changed.
                            ---@diagnostic disable-next-line: inject-field
                            new_config.settings = vim.tbl_deep_extend("keep", new_config.settings, {
                                format = {
                                    args = ruff.format_args(),
                                },
                                lint = {
                                    args = ruff.check_args(),
                                },
                            })
                        end,
                        root_dir = function(fname)
                            return require("lspconfig.util").root_pattern("pyproject.toml", "setup.cfg", "ruff.toml")(fname)
                        end,
                        settings = {
                            codeAction = {
                                fixViolation = {
                                    enable = true,
                                },
                                disableRuleComment = {
                                    enable = false,
                                },
                            },
                        },
                    },
                    rust_analyzer = {
                        ---@param client lsp.Client
                        ---@param bufnr integer
                        on_attach = function(client, bufnr)
                            local cmd = require("config.defaults").cmd
                            local e = require("helpers.event")

                            vim.cmd.compiler("cargo")

                            vim.keymap.set("n", "<localleader>t", cmd("make test -q"), { desc = "Cargo test" })
                            vim.keymap.set("n", "<localleader>b", cmd("make build"), { desc = "Cargo build" })
                            vim.keymap.set("n", "<localleader>c", cmd("make clippy -q"), { desc = "Cargo clippy" })

                            client.server_capabilities.experimental.commands = {
                                commands = {
                                    "rust-analyzer.runSingle",
                                    "rust-analyzer.debugSingle",
                                    "rust-analyzer.showReferences",
                                    "rust-analyzer.gotoLocation",
                                    "editor.action.triggerParameterHints",
                                },
                            }

                            client.server_capabilities.experimental.codeActionGroup = true
                            client.server_capabilities.experimental.hoverActions = true
                            client.server_capabilities.experimental.serverStatusNotification = true
                            client.server_capabilities.experimental.snippetTextEdit = true

                            vim.keymap.set("n", "<leader>ce", function()
                                ---
                                client.request("experimental/openCargoToml", {
                                    textDocument = vim.lsp.util.make_text_document_params(bufnr),
                                }, function(_, result, ctx)
                                    --
                                    if result ~= nil then
                                        vim.lsp.util.jump_to_location(result, vim.lsp.get_client_by_id(ctx.client_id).offset_encoding)
                                    end
                                end, bufnr)
                            end, { desc = "Open Cargo.toml" })

                            e.on(e.BufWritePost, function()
                                local handler = function(err)
                                    if err then
                                        local msg = string.format("Error reloading Rust workspace: %v", err)
                                        vim.notify(msg, vim.lsp.log_levels.ERROR, {
                                            title = "Reloading Rust workspace",
                                            timeout = 3000,
                                        })
                                    else
                                        vim.notify("Workspace has been reloaded")
                                    end
                                end

                                client.request("rust-analyzer/reloadWorkspace", nil, handler, bufnr)
                            end, {
                                desc = "Apply Cargo.toml changes after edit.",
                                pattern = "*/Cargo.toml",
                            })
                        end,
                        standalone = false,
                    },
                    yamlls = {
                        filetypes = { "yaml", "yaml.ghaction", "!yaml.ansible" },
                        on_new_config = function(c)
                            c.settings.yaml.schemas = vim.tbl_deep_extend("force", c.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())

                            require("yaml-companion").setup({
                                builtin_matchers = {
                                    cloud_init = { enabled = false },
                                    kubernetes = { enabled = false },
                                },
                            })
                        end,
                    },
                },
            }

            return opts
        end,
    },
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        cmd = {
            "Mason",
            "MasonInstall",
            "MasonUninstall",
            "MasonUpdate",
            "MasonToolsInstall",
            "MasonToolsUpdate",
        },
        opts = {
            ensure_installed = {
                "codelldb",
                "gitui",
                "jdtls",
                "write-good",
            },
            ui = {
                border = vim.g.border,
            },
        },
        ---@param opts MasonSettings | {ensure_installed: string[]}
        config = function(_, opts)
            require("mason").setup(opts)

            vim.schedule_wrap(function()
                local defaults = require("config.defaults")
                local mr = require("mason-registry")

                vim.list_extend(opts.ensure_installed, vim.tbl_flatten(vim.tbl_values(defaults.formatters)))
                vim.list_extend(opts.ensure_installed, vim.tbl_flatten(vim.tbl_values(defaults.linters)))

                -- Remove built-ins / formatters that are not in Mason.
                opts.ensure_installed = vim.iter.filter(function(t)
                    return not vim.tbl_contains(defaults.ignored.tools, t)
                end, opts.ensure_installed)

                vim.iter(opts.ensure_installed):each(function(tool)
                    local p = mr.get_package(tool)

                    if p:is_installed() then
                        return
                    end

                    vim.notify(("Installing %s"):format(p.name), vim.log.levels.INFO, { title = "Mason", render = "compact" })

                    local handle_closed = vim.schedule_wrap(function()
                        return p:is_installed()
                            and vim.notify(("Successfully installed %s"):format(p.name), vim.log.levels.INFO, { title = "Mason", render = "compact" })
                    end)

                    p:install():once("closed", handle_closed)
                end)
            end)
        end,
    },
    { "microsoft/python-type-stubs" },
    {
        "pmizio/typescript-tools.nvim",
        event = {
            "BufReadPre *.ts,*.tsx,*.js,*.jsx",
            "BufNewFile *.ts,*.tsx,*.js,*.jsx",
        },
        dependencies = { "nvim-lua/plenary.nvim", "nvim-lspconfig" },
        opts = function()
            return {
                capabilities = require("plugins.lsp.common").capabilities(),
                settings = {
                    code_lens = "on",
                    expose_as_code_actions = { "all" },
                    publish_diagnostic_on = "insert_leave",
                    tsserver_file_preferences = {
                        includeInlayEnumMemberValueHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayParameterNameHints = "all",
                        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayVariableTypeHints = true,
                        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    },
                    tsserver_format_preferences = {
                        convertTabsToSpaces = true,
                        indentSize = 2,
                        trimTrailingWhitespace = false,
                        semicolons = "insert",
                    },
                },
            }
        end,
    },
    { "p00f/clangd_extensions.nvim" },
    { "someone-stole-my-name/yaml-companion.nvim" },
}
