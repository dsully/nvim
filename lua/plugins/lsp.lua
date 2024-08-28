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
            require("lspconfig.ui.windows").default_options.border = defaults.ui.border.name

            vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

            local lsp = require("helpers.lsp")
            local capabilities = lsp.capabilities()
            local methods = vim.lsp.protocol.Methods

            lsp.setup()
            lsp.on_dynamic_capability(function() end)

            lsp.on_supports_method(methods.textDocument_inlayHint, function()
                vim.lsp.inlay_hint.enable(false)
            end)

            -- Disable codeLens for now.
            -- lsp.on_supports_method(methods.textDocument_codeLens, function(_, buffer)
            --     vim.lsp.codelens.refresh()
            --
            --     ev.on({ ev.BufEnter, ev.CursorHold, ev.InsertLeave }, vim.lsp.codelens.refresh, {
            --         buffer = buffer,
            --     })
            -- end)

            lsp.on_supports_method(methods.textDocument_documentHighlight, function(client, buffer)
                local group = ev.group(("%s/buffer/%s"):format(client.name, buffer))

                ev.on({ ev.CursorHold, ev.CursorHoldI, ev.InsertLeave }, function()
                    if vim.api.nvim_buf_is_valid(buffer) then
                        vim.lsp.buf.document_highlight()
                    end
                end, {
                    group = group,
                    buffer = buffer,
                    desc = "LSP: Highlight symbol",
                })

                ev.on({ ev.BufLeave, ev.CursorMoved, ev.InsertEnter }, function()
                    if vim.api.nvim_buf_is_valid(buffer) then
                        vim.lsp.buf.clear_references()
                    end
                end, {
                    group = group,
                    buffer = buffer,
                    desc = "LSP: Clear highlighted symbol",
                })
            end)

            local handlers = {}

            ---@type table<string, string>
            local mason_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)

            for name, handler in pairs(opts.servers) do
                if handler.enabled ~= false then
                    --
                    local setup = function()
                        require("lspconfig")[name].setup(vim.tbl_deep_extend("force", { capabilities = capabilities }, handler))
                    end

                    -- Run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
                    if handler.mason == false or not vim.tbl_contains(mason_servers, name) then
                        setup()
                    else
                        handlers[name] = setup
                    end
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
                "folke/lazydev.nvim",
                cmd = "LazyDev",
                ft = "lua",
                opts = {
                    library = {
                        "luvit-meta/library",
                        "nvim-cokeline",
                    },
                },
            },
            { "Bilal2453/luvit-meta" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
        },
        event = ev.LazyFile,
        init = function()
            vim.lsp.set_log_level(vim.log.levels.ERROR)

            vim.api.nvim_create_user_command("LspCapabilities", function()
                --
                ---@type vim.lsp.Client[]
                local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })

                local lines = {}

                for i, client in ipairs(clients) do
                    if not vim.tbl_contains(defaults.ignored.lsp, client.name) then
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

                require("helpers.float").open({ filetype = "lua", lines = lines, window = { width = 0.8 } })
            end, { desc = "Show LSP Capabilities" })

            vim.api.nvim_create_user_command("LspRestartBuffer", function()
                --
                require("helpers.lsp").apply_to_buffers(function(bufnr, client)
                    --
                    vim.lsp.stop_client(client.id, true)

                    vim.notify(("Restarting LSP %s for %s"):format(client.name, vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))))
                end, { bufnr = vim.api.nvim_get_current_buf() })

                vim.cmd.edit()
            end, { desc = "Restart Language Server for Buffer" })

            ev.on_load("which-key.nvim", function()
                vim.schedule(function()
                    require("which-key").add({
                        { "grn", require("helpers.lsp").rename, desc = "Rename", icon = "" },
                        { "<C-S>", vim.lsp.buf.signature_help, desc = "Signature Help", mode = "i", icon = "󰠗" },
                        { "gra", vim.lsp.buf.code_action, desc = "Actions", icon = "󰅯" },
                        { "<leader>l", group = "LSP", icon = "" },
                        { "<leader>lc", vim.cmd.LspCapabilities, desc = "LSP Capabilities", icon = "" },
                        { "<leader>li", vim.cmd.LspInfo, desc = "LSP Info", icon = "" },
                        { "<leader>ll", vim.cmd.LspLog, desc = "LSP Log", icon = "" },
                        { "<leader>lr", vim.cmd.LspRestartBuffer, desc = "LSP Restart", icon = "" },
                        { "<leader>ls", vim.cmd.LspStop, desc = "LSP Stop", icon = "" },
                        { "<leader>xr", vim.diagnostic.reset, desc = "Reset", icon = "" },
                        { "<leader>xs", vim.diagnostic.open_float, desc = "Show", icon = "󰙨" },
                    }, { notify = false })
                end)
            end)
        end,
        opts = function()
            ---@class PluginLspOpts
            local opts = {
                ---@type vim.diagnostic.Opts
                diagnostics = {
                    float = {
                        border = defaults.ui.border.name,
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
                },
                servers = {
                    basedpyright = {
                        settings = {
                            basedpyright = {
                                analysis = {
                                    autoImportCompletions = false,
                                    autoSearchPaths = true,
                                    diagnosticMode = "openFilesOnly",
                                    reportMissingTypeStubs = false,
                                    reportUnreachable = true,
                                    typeCheckingMode = "standard",
                                    useLibraryCodeForTypes = true,
                                },
                            },
                        },
                    },
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
                    -- ccls = {
                    --     capabilities = capabilities,
                    --     filetypes = { "c", "cpp", "cuda" },
                    --     init_options = {
                    --         clang = {
                    --             excludeArgs = { "-frounding-math" },
                    --         },
                    --         compilationDatabaseDirectory = "build",
                    --         index = {
                    --             threads = 0,
                    --         },
                    --     },
                    --     mason = false,
                    --     offset_encoding = "utf-32",
                    -- }
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
                    fish_lsp = {
                        initializationOptions = {
                            workspaces = {
                                paths = {
                                    defaults = {
                                        vim.env.HOME .. "/.config/fish",
                                        vim.env.HOMEBREW_PREFIX .. "/share/fish/",
                                    },
                                },
                            },
                        },
                        mason = false,
                    },
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
                    -- jedi_language_server = {
                    --     ---@param client vim.lsp.Client
                    --     on_attach = function(client)
                    --         client.server_capabilities.codeActionProvider = false
                    --     end,
                    -- },
                    jsonls = {
                        on_new_config = function(c)
                            c.settings = vim.tbl_deep_extend("force", c.settings, { json = { schemas = require("schemastore").json.schemas() } })
                        end,
                    },
                    lemminx = {}, -- XML
                    lua_ls = {},
                    marksman = {},
                    ruff = {
                        commands = {
                            RuffAutoFix = {
                                require("helpers.lsp").action["source.fixAll"],
                                description = "Ruff: Auto Fix",
                            },
                            RuffOrganizeImports = {
                                require("helpers.lsp").action["source.organizeImports"],
                                description = "Ruff: Organize Imports",
                            },
                        },
                        init_options = {
                            settings = require("helpers.ruff").config(),
                        },
                        -- Use ruff from Homebrew
                        mason = false,
                        ---@param client vim.lsp.Client
                        on_attach = function(client)
                            client.server_capabilities.hoverProvider = false
                        end,
                    },
                    sourcekit = {
                        filetypes = { "objc", "objcpp", "swift" }, -- Handle Swift only.
                        mason = false,
                    },
                    taplo = {
                        filetypes = { "toml", "toml.pyproject" },
                        ---@param client vim.lsp.Client
                        on_attach = function(client)
                            --
                            -- Disable until the issue below is addressed.
                            client.server_capabilities.documentFormattingProvider = false
                            client.server_capabilities.documentRangeFormattingProvider = false
                            client.server_capabilities.documentOnTypeFormattingProvider = nil

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
        opts = {
            ---@type string[]
            ensure_installed = defaults.tools,
            registries = {
                "github:nvim-java/mason-registry",
                "github:mason-org/mason-registry",
            },
            ui = {
                border = defaults.ui.border.name,
            },
        },
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
                capabilities = require("helpers.lsp").capabilities(),
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
    -- TODO: Replace with https://github.com/cenk1cenk2/yaml-companion.nvim
    { "someone-stole-my-name/yaml-companion.nvim" },
    {
        "https://gitlab.com/schrieveslaach/sonarlint.nvim",
        config = function()
            -- https://gitlab.com/schrieveslaach/sonarlint.nvim/-/issues/18
            vim.lsp.handlers["sonarlint/listFilesInFolder"] = function(_, params)
                local result = {
                    foundFiles = {},
                }

                for _, path in ipairs(vim.fs.find("*", { path = params.folderUri, type = "file" })) do
                    table.insert(result.foundFiles, {
                        fileName = vim.fs.basename(path),
                        filePath = path,
                    })
                end

                return result
            end

            require("sonarlint").setup({
                server = {
                    cmd = {
                        "sonarlint-language-server",
                        "-stdio",
                        "-analyzers",
                        vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarpython.jar"),
                    },
                    settings = {
                        sonarlint = {
                            test = "test",
                        },
                    },
                },
                filetypes = {
                    "python",
                },
            })
        end,
        ft = "python",
    },
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = ev.LspAttach,
        init = function()
            vim.diagnostic.config({ virtual_text = false })
        end,
        opts = {
            hi = {
                background = defaults.colors.black.dim,
            },
            options = {
                multiple_diag_under_cursor = true,
                show_source = true,
                throttle = 0,
            },
            signs = {
                left = " ",
                right = "",
            },
        },
    },
}
