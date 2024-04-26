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

            vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

            local capabilities = require("plugins.lsp.common").setup()
            local handlers = {}

            if vim.g.os == "Darwin" then
                require("lspconfig").sourcekit.setup({
                    capabilities = capabilities,
                    filetypes = { "objective-c", "objective-cpp", "swift" }, -- Handle Swift. Let clangd handle C/C++
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
                    {
                        "folke/neoconf.nvim",
                        cmd = "Neoconf",
                        opts = {
                            local_settings = ".neoconf.jsonc",
                            global_settings = "neoconf.jsonc",
                        },
                    },
                },
                opts = true,
            },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
        },
        event = "LazyFile",
        init = function()
            vim.lsp.set_log_level(vim.log.levels.ERROR)

            vim.api.nvim_create_user_command("LspCapabilities", function()
                --
                ---@type vim.lsp.Client[]
                local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })

                local lines = {}

                for i, client in ipairs(clients) do
                    if not vim.tbl_contains(require("config.defaults").ignored.lsp, client.name) then
                        table.insert(lines, client.name .. " Capabilities: ")
                        table.insert(lines, "")

                        for s in vim.inspect(client.server_capabilities):gmatch("[^\r\n]+") do
                            table.insert(lines, s)
                        end

                        if client.config.settings then
                            table.insert(lines, "")
                            table.insert(lines, client.name .. " Config: ")
                            table.insert(lines, "")

                            for s in vim.inspect(client.config.settings):gmatch("[^\r\n]+") do
                                table.insert(lines, s)
                            end
                        end

                        if i < #clients then
                            table.insert(lines, "")
                        end
                    end
                end

                require("helpers.float").open({ filetype = "lua", lines = lines, width = 0.8 })
            end, { desc = "Show LSP Capabilities" })

            vim.api.nvim_create_user_command("LspRestartBuffer", function()
                local bufnr = vim.api.nvim_get_current_buf()

                ---@type vim.lsp.Client[]
                local clients = vim.iter(vim.lsp.get_clients({ bufnr = bufnr })):filter(function(client)
                    return not vim.tbl_contains(require("config.defaults").ignored.lsp, client.name)
                end)

                for _, client in ipairs(clients) do
                    vim.lsp.stop_client(client.id, true)
                end

                vim.notify(("Restarting LSPs for: %s -> %s"):format(
                    vim.fs.basename(vim.api.nvim_buf_get_name(bufnr)),
                    vim.fn.join(
                        vim.tbl_map(function(client)
                            return client.name
                        end, clients),
                        ", "
                    )
                ))

                vim.cmd.edit()
            end, { desc = "Restart Language Server for Buffer" })
        end,
        keys = {
            -- Telescope based finders via telescope-lsp.nvim
            { "gD", vim.lsp.buf.declaration, desc = "󰁴 Go To Declaration" },
            { "gd", vim.lsp.buf.definition, desc = "󰁴 Go To Definition(s)" },
            { "gi", vim.lsp.buf.implementation, desc = "󰘲 Go To Implementations(s)" },
            { "<leader>fS", vim.lsp.buf.document_symbol, desc = "󰆋 Symbols" },
            { "<leader>fW", vim.lsp.buf.workspace_symbol, desc = "󰆋 Workspace Symbols" },
            {
                "dt",
                function()
                    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
                end,
                noremap = true,
                desc = "Diagnostics Toggle",
            },
            { "<leader>lc", vim.cmd.LspCapabilities, desc = " LSP Capabilities" },
            { "<leader>li", vim.cmd.LspInfo, desc = " LSP Info" },
            { "<leader>ll", vim.cmd.LspLog, desc = " LSP Log" },
            { "<leader>lr", vim.cmd.LspRestartBuffer, desc = " LSP Restart" },
            { "<leader>ls", vim.cmd.LspStop, desc = " LSP Stop" },
            { "<leader>xr", vim.diagnostic.reset, desc = " Reset" },
            { "<leader>xs", vim.diagnostic.open_float, desc = "󰙨 Show" },
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
                        header = { "" },
                        severity_sort = true,
                        spacing = 2,
                        source = true,
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
                    bashls = {
                        filetypes = { "bash", "direnv", "sh" },
                        settings = {
                            bashls = {
                                bashIde = {
                                    includeAllWorkspaceSymbols = true,
                                },
                            },
                        },
                    },
                    bzl = {},
                    clangd = {
                        capabilities = {
                            offsetEncoding = { "utf-16" },
                        },
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
                        settings = {
                            clangd = {
                                semanticHighlighting = true,
                                single_file_support = false,
                            },
                        },
                    },
                    cssls = {},
                    dockerls = {},
                    gopls = {
                        filetypes = { "go", "gomod", "gowork" }, -- Don't attach for gotmpl.
                        init_options = {
                            usePlaceholders = true,
                        },
                        ---@param client vim.lsp.Client
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
                        settings = {
                            gopls = {
                                analyses = {
                                    fieldalignment = true,
                                    nilness = true,
                                    shadow = true,
                                    unusedparams = true,
                                    unusedwrite = true,
                                    useany = true,
                                },
                                codelenses = {
                                    gc_details = false,
                                    generate = true,
                                    regenerate_cgo = true,
                                    run_govulncheck = true,
                                    test = true,
                                    tidy = true,
                                    upgrade_dependency = true,
                                    vendor = true,
                                },
                                completeUnimported = true,
                                directoryFilters = {
                                    "-.git",
                                    "-.vscode",
                                    "-.idea",
                                    "-.vscode-test",
                                    "-node_modules",
                                },
                                experimentalPostfixCompletions = true,
                                gofumpt = true,
                                hints = {
                                    assignVariableTypes = true,
                                    compositeLiteralFields = true,
                                    compositeLiteralTypes = true,
                                    constantValues = true,
                                    functionTypeParameters = true,
                                    parameterNames = true,
                                    rangeVariableTypes = true,
                                },
                                semanticTokens = true,
                                staticcheck = true,
                                usePlaceholders = true,
                            },
                        },
                    },
                    gradle_ls = {},
                    html = {},
                    jedi_language_server = {
                        ---@param client vim.lsp.Client
                        on_attach = function(client)
                            client.server_capabilities.codeActionProvider = false
                        end,
                    },
                    jsonls = {
                        on_new_config = function(c)
                            c.settings = vim.tbl_deep_extend("force", c.settings, { json = { schemas = require("schemastore").json.schemas() } })
                        end,
                    },
                    lemminx = {}, -- XML
                    lua_ls = {
                        before_init = function(params, config)
                            -- Add libuv to the workspace library for type hints.
                            if config.settings.Lua then
                                table.insert(config.settings.Lua.workspace.library, "${3rd}/luv/library")
                            end

                            return require("neodev.lsp").before_init(params, config)
                        end,
                    },
                    markdown_oxide = {},
                    ruff = {
                        commands = {
                            RuffAutoFix = {
                                function()
                                    vim.lsp.buf.code_action({ context = { only = { "source.fixAll" } }, apply = true })
                                end,
                                description = "Ruff: Auto Fix",
                            },

                            RuffOrganizeImports = {
                                function()
                                    vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
                                end,
                                description = "Ruff: Organize Imports",
                            },
                        },
                        filetypes = { "python", "toml.pyproject" },
                        on_new_config = function()
                            require("helpers.ruff").write_config()
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
                        ---@param client vim.lsp.Client
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

                            client.server_capabilities.experimental.codeActionGroup = false
                            client.server_capabilities.experimental.localDocs = false
                            client.server_capabilities.experimental.hoverActions = true
                            client.server_capabilities.experimental.serverStatusNotification = true
                            client.server_capabilities.experimental.snippetTextEdit = true

                            vim.keymap.set({ "n", "x" }, "gx", function()
                                client.request("experimental/externalDocs", vim.lsp.util.make_position_params(), function(_, url)
                                    if url then
                                        vim.system({ vim.g.opener, "--background", url }):wait()
                                    else
                                        vim.cmd.Browse()
                                    end
                                end, vim.api.nvim_get_current_buf())
                            end)

                            vim.keymap.set("n", "<leader>ce", function()
                                ---
                                -- method, parameters, callback, bufnr
                                client.request("experimental/openCargoToml", {
                                    textDocument = vim.lsp.util.make_text_document_params(),
                                }, function(_, result, ctx)
                                    --
                                    if result ~= nil then
                                        vim.lsp.util.jump_to_location(result, vim.lsp.get_client_by_id(ctx.client_id).offset_encoding)
                                    end
                                end, vim.api.nvim_get_current_buf())
                            end, { desc = "Open Cargo.toml" })

                            e.on(e.BufWritePost, function()
                                local handler = function(err)
                                    if err then
                                        local msg = string.format("Error reloading Rust workspace: %v", err)
                                        vim.notify(msg, vim.log.levels.ERROR, {
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
                        settings = {
                            ["rust-analyzer"] = {
                                cargo = {
                                    autoreload = true,
                                    features = "all",
                                },
                                check = {
                                    command = "clippy",
                                    enable = true,
                                    extraArgs = { "--no-deps" },
                                },
                                checkOnSave = {
                                    command = "clippy",
                                    enable = true,
                                    extraArgs = { "--no-deps" },
                                },
                                completion = {
                                    autoimport = true,
                                    autoself = true,
                                    fullFunctionSignatures = { enable = true },
                                },
                                diagnostics = {
                                    disabled = { "inactive-code", "macro-error", "unresolved-macro-call" },
                                    experimental = {
                                        enable = true,
                                    },
                                },
                                files = {
                                    excludeDirs = {
                                        ".direnv",
                                        ".git",
                                        ".vscode",
                                        "assets",
                                        "ci",
                                        "data",
                                        "docs",
                                        "js",
                                        "target",
                                    },
                                },
                                hover = {
                                    actions = {
                                        references = { enable = true },
                                    },
                                },
                                imports = {
                                    granularity = {
                                        group = "module",
                                    },
                                    prefix = "self",
                                },
                                inlayHints = {
                                    chainingHints = { enable = true },
                                    closureReturnTypeHints = { enable = "with_block" },
                                    parameterHints = { enable = false },
                                },
                                interpret = {
                                    tests = true,
                                },
                                lens = {
                                    references = {
                                        adt = { enable = true },
                                        method = { enable = true },
                                        enumVariant = { enable = true },
                                        trait = { enable = true },
                                    },
                                },
                                lru = {
                                    capacity = 512,
                                },
                                references = {
                                    excludeImports = true,
                                },
                                rust = {
                                    analyzerTargetDir = true,
                                },
                                semanticHighlighting = {
                                    operator = {
                                        specialization = { enable = true },
                                    },
                                },
                                typing = {
                                    autoClosingAngleBrackets = { enable = true },
                                },
                                workspace = {
                                    symbol = {
                                        search = {
                                            kind = "all_symbols",
                                        },
                                    },
                                },
                            },
                        },
                        standalone = false,
                    },
                    taplo = {
                        filetypes = { "toml", "toml.pyproject" },
                        ---@param client vim.lsp.Client
                        on_attach = function(client)
                            vim.keymap.set("n", "<leader>vs", function()
                                local bufnr = vim.api.nvim_get_current_buf()

                                client.request(
                                    "taplo/associatedSchema",
                                    vim.tbl_extend("force", vim.lsp.util.make_position_params(), { documentUri = vim.uri_from_bufnr(bufnr) }),
                                    function(_, result)
                                        vim.notify(vim.inspect(result))
                                    end,
                                    bufnr
                                )
                            end, { buffer = true, desc = "Show associated TOML schema" })
                        end,
                        -- This doesn't work. https://github.com/tamasfe/taplo/issues/560
                        settings = {
                            taplo = {
                                config_file = {
                                    enabled = true,
                                    path = vim.env.XDG_CONFIG_HOME .. "/taplo.toml",
                                },
                            },
                        },
                    },
                    typos_lsp = {
                        cmd = { "typos-lsp", "--config", vim.env.HOME .. "/.typos.toml" },
                        init_options = {
                            diagnosticSeverity = "Warning",
                        },
                    },
                    yamlls = {
                        commands = {
                            YAMLSchema = {
                                function()
                                    local schema = require("yaml-companion").get_buf_schema(vim.api.nvim_get_current_buf())

                                    if schema.result[1].name ~= "none" then
                                        vim.notify(schema.result[1].name)
                                    end
                                end,
                                desc = "Show YAML schema",
                            },
                        },
                        filetypes = { "yaml", "yaml.ghaction", "!yaml.ansible" },
                        on_new_config = function(c)
                            c.settings = vim.tbl_deep_extend("force", c.settings, { yaml = { schemas = require("schemastore").yaml.schemas() } })

                            require("yaml-companion").setup({
                                builtin_matchers = {
                                    cloud_init = { enabled = false },
                                    kubernetes = { enabled = false },
                                },
                            })

                            -- vs = View Schema
                            vim.keymap.set("n", "<leader>vs", vim.cmd.YAMLSchema, { buffer = true, desc = "Show YAML schema" })

                            vim.keymap.set("n", "<leader>fy", function()
                                require("telescope").extensions.yaml_schema.yaml_schema()
                            end, { buffer = true, desc = "YAML Schemas" })
                        end,
                        settings = {
                            yaml = {
                                validate = true,
                                format = {
                                    enable = true,
                                    singleQuote = false,
                                },
                                hover = true,
                            },
                        },
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
            ---@type string[]
            ensure_installed = require("config.defaults").tools,
            registries = {
                "github:nvim-java/mason-registry",
                "github:mason-org/mason-registry",
            },
            ui = {
                border = vim.g.border,
            },
        },
        config = function(_, opts)
            require("mason").setup(opts)

            vim.schedule(function()
                local mr = require("mason-registry")

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
