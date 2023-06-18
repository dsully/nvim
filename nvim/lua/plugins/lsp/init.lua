local common = require("plugins.lsp.common")

local servers = {
    bashls = {
        filetypes = { "bash", "sh", "zsh" },
    },
    bufls = {},
    cmake = {},
    cssls = {},
    dockerls = {},
    esbonio = {}, -- RestructuredText
    graphql = {},
    html = {},
    kotlin_language_server = {},
    lemminx = {}, -- XML
    marksman = {}, -- Markdown
    -- pylyzer",
    terraformls = {},
    clangd = function()
        -- https://github.com/p00f/clangd_extensions.nvim
        require("clangd_extensions").setup({
            server = {
                capabilities = vim.tbl_extend("force", common.capabilities(), {
                    textDocument = {
                        completion = {
                            editsNearCursor = true,
                        },
                    },
                    offsetEncoding = { "utf-16" },
                }),
                -- https://github.com/hrsh7th/nvim-cmp/issues/999
                cmd = {
                    "clangd",
                    "--all-scopes-completion",
                    "--clang-tidy",
                    "--completion-style=detailed",
                    "--header-insertion-decorators",
                },
                -- Don't want objective-c and objective-cpp.
                filetypes = { "c", "cpp", "cuda" },
                on_attach = common.on_attach,
            },
            extensions = {
                autoSetHints = true,
                hover_with_actions = false,
            },
        })
    end,
    gopls = {
        filetypes = { "go", "gomod", "gowork" },
        init_options = {
            usePlaceholders = true,
        },
        on_attach = function(client, ...)
            -- As of v0.11.0, gopls does not send a Semantic Token legend (in a
            -- client/registerCapability message) unless the client supports dynamic
            -- registration. Neovim's LSP client does not support dynamic registration
            -- for semantic tokens, so we need to declare those server_capabilities
            -- ourselves for the time being.
            -- Ref. https://github.com/golang/go/issues/54531
            client.server_capabilities.semanticTokensProvider = {
                full = true,
                legend = {
                    tokenModifiers = client.config.capabilities.textDocument.semanticTokens.tokenModifiers,
                    tokenTypes = client.config.capabilities.textDocument.semanticTokens.tokenTypes,
                },
                range = true,
            }
            common.on_attach(client, ...)
        end,
        settings = {
            gopls = {
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },
                experimentalPostfixCompletions = true,
                analyses = {
                    unusedparams = true,
                    shadow = true,
                },
                semanticTokens = true,
                staticcheck = true,
            },
        },
    },
    gradle_ls = {
        on_attach = function(client, ...)
            common.on_attach(client, ...)
            vim.lsp.handlers["textDocument/references"] = nil
        end,
    },
    jsonls = {
        before_init = function(_, config)
            config.settings.json.schemas = require("schemastore").json.schemas()
        end,
        filetypes = { "json", "json5", "jsonc" },
    },
    lua_ls = {
        settings = {
            Lua = {
                completion = {
                    callSnippet = "Both",
                    keywordSnippet = "Replace",
                    workspaceWord = true,
                },
                diagnostics = {
                    -- Have the language server to recognize the `vim` global.
                    globals = { "bit", "vim" },
                },
                format = {
                    enable = false,
                },
                hint = {
                    enable = true,
                    arrayIndex = "Disable",
                    setType = true,
                    paramName = "Disable",
                },
                runtime = {
                    version = "Lua 5.1",
                },
                telemetry = {
                    enable = false,
                },
                workspace = {
                    checkThirdParty = false,
                },
            },
        },
    },
    pylsp = {
        before_init = function(_, config)
            config.settings.pylsp.plugins.ruff = require("plugins.lsp.python").ruff_config()
        end,
        cmd = { "pylsp", "--check-parent-process" },
        settings = {
            pylsp = {
                configurationSources = {},
                plugins = {
                    autopep8 = { enabled = false },
                    isort = { enabled = false },
                    jedi_completion = {
                        enabled = true,
                        include_class_objects = true,
                        include_function_objects = true,
                        include_params = true,
                    },
                    mccabe = { enabled = false },
                    preload = { enabled = false },
                    pycodestyle = { enabled = false },
                    pyflakes = { enabled = false },
                    pylsp_mypy = {
                        enabled = true,
                        live_mode = true,
                        report_progress = true,
                        dmypy = true,
                    },
                    yapf = { enabled = false },
                },
            },
        },
    },

    -- pylance = function()
    --     require("lspconfig").pylance.setup({
    --         before_init = function(_, config)
    --             local path = require("lspconfig/util").path
    --             config.settings.python.analysis.stubPath = path.join(vim.fn.stdpath("data"), "lazy", "python-type-stubs")
    --         end,
    --         capabilities = common.capabilities(),
    --         on_attach = function(client, ...)
    --             -- Disable capabilities that are better handled by pylsp
    --             client.server_capabilities.renameProvider = false -- Use Rope.
    --             client.server_capabilities.hoverProvider = false -- pylsp includes docstrings
    --             client.server_capabilities.signatureHelpProvider = false -- pyright typing of signature is weird
    --             client.server_capabilities.definitionProvider = false -- pyright does not follow imports correctly
    --             client.server_capabilities.referencesProvider = false
    --             client.server_capabilities.completionProvider = {
    --                 resolveProvider = true,
    --                 triggerCharacters = { "." },
    --             }
    --             common.on_attach(client, ...)
    --         end,
    --         on_new_config = function(config, root)
    --             config.settings.python.pythonPath = vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
    --
    --             -- PEP 582 support
    --             local pypackages = require("lspconfig.util").path.join(root, "__pypackages__", "lib")
    --
    --             if vim.uv.fs_stat(pypackages) then
    --                 config.settings.python.analysis.extraPaths = { pypackages }
    --             end
    --         end,
    --         settings = {
    --             python = {
    --                 -- https://github.com/microsoft/pyright/blob/main/docs/configuration.md
    --                 -- https://github.com/microsoft/pyright/blob/main/docs/settings.md
    --                 analysis = {
    --                     autoImportCompletions = true,
    --                     autoSearchPaths = true,
    --                     diagnosticMode = "workspace",
    --                     diagnosticSeverityOverrides = {
    --                         reportImportCycles = "none",
    --                         reportMissingImports = "none",
    --                         reportMissingTypeStubs = "none",
    --                         reportPrivateUsage = "none",
    --                         reportUnknownMemberType = "none",
    --                         reportUnknownVariableType = "none",
    --                         reportUnusedImport = "none",
    --                     },
    --                     inlayHints = {
    --                         variableTypes = true,
    --                         functionReturnTypes = true,
    --                     },
    --                     typeCheckingMode = "off", -- off, basic or strict
    --                 },
    --                 disableOrganizeImports = true, -- Use isort or ruff instead.
    --             },
    --         },
    --     })
    -- end,

    -- https://docs.rome.tools
    rome = {
        cmd = { "rome", "lsp-proxy", "--config-path", vim.env.XDG_CONFIG_HOME },
    },

    ruff_lsp = function()
        require("lspconfig").ruff_lsp.setup({
            init_options = {
                settings = {
                    args = require("plugins.lsp.python").ruff_args(),
                },
            },
            on_attach = function(client)
                client.server_capabilities.hoverProvider = false
            end,
            root_dir = function(fname)
                return require("lspconfig.util").root_pattern("pyproject.toml", "setup.cfg", "ruff.toml")(fname)
            end,
        })
    end,

    rust_analyzer = function()
        require("rust-tools").setup({
            tools = {
                inlay_hints = {
                    auto = true,
                },
                hover_actions = {
                    auto_focus = true,
                },
            },
            server = {
                before_init = function(_, config)
                    -- Override clippy to run in its own directory to avoid clobbering caches.
                    local target = "--target-dir=" .. config.root_dir .. "/target/ide-clippy"

                    table.insert(config.settings["rust-analyzer"].checkOnSave.extraArgs, target)
                end,
                capabilities = common.capabilities(),
                on_attach = function(client, ...)
                    client.server_capabilities.experimental.hoverActions = true
                    client.server_capabilities.experimental.hoverRange = true
                    client.server_capabilities.experimental.serverStatusNotification = true
                    client.server_capabilities.experimental.snippetTextEdit = true
                    client.server_capabilities.experimental.codeActionGroup = true
                    client.server_capabilities.experimental.ssr = true
                    common.on_attach(client, ...)
                end,
                settings = {
                    -- https://rust-analyzer.github.io/manual.html
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                            allTargets = true,
                            extraEnv = { CARGO_INCREMENTAL = "0" }, -- Use sccache
                        },
                        check = {
                            command = "clippy",
                            extraArgs = {
                                "--no-deps",
                                "--",
                                "-W",
                                "correctness",
                                "-W",
                                "keyword_idents",
                                "-W",
                                "rust_2021_prelude_collisions",
                                "-W",
                                "trivial_casts",
                                "-W",
                                "trivial_numeric_casts",
                                "-W",
                                "unused_lifetimes",
                            },
                        },
                        -- https://github.com/rust-analyzer/rust-analyzer/issues/6835
                        diagnostics = {
                            disabled = { "inactive-code", "unresolved-macro-call" },
                            experimental = { enable = true },
                        },
                        files = {
                            excludeDirs = {
                                "./assets/",
                                "./data/",
                                "./docs/",
                                "./.vscode/",
                                "./.git/",
                            },
                        },
                        inlayHints = {
                            -- Whether to show inlay hints for closure captures.
                            -- https://rust-analyzer.github.io//thisweek/2023/05/15/changelog-181.html#new-features
                            closureCaptureHints = { enable = false }, -- default : false

                            -- Whether to show inlay type hints for return types of closures.
                            closureReturnTypeHints = { enable = "with_block" }, --default: "never", options: "always", "never", "with_block"
                        },
                        lru = { capacity = 2048 },
                        procMacro = { enable = true },
                        workspace = {
                            symbol = {
                                search = {
                                    scope = "workspace_and_dependencies",
                                },
                            },
                        },
                    },
                },
                standalone = false,
            },
        })
    end,

    taplo = {
        settings = {
            evenBetterToml = {
                schema = {
                    enabled = true,
                    repositoryEnabled = true,
                    repositoryUrl = "https://taplo.tamasfe.dev/schema_index.json",
                },
                formatter = {
                    arrayTrailingComma = true,
                    arrayAutoExpand = true,
                    arrayAutoCollapse = false,
                    compactArrays = false,
                    compactInlineTables = false,
                    indentTables = true,
                    trailingNewline = false,
                    reorderKeys = true,
                },
            },
        },
    },

    tsserver = function()
        require("typescript").setup({
            debug = false,
            disable_commands = false,
            disable_formatting = true,
            go_to_source_definition = {
                fallback = true, -- Fall back to standard LSP definition on failure.
            },
            server = {
                capabilities = common.capabilities(),
                filetypes = { "javascript", "javascript.jsx", "typescript", "typescript.tsx" },
                on_attach = common.on_attach,
                settings = {
                    completions = {
                        completeFunctionCalls = true,
                    },
                },
            },
        })

        -- Inject code actions to null-ls.
        require("null-ls").register(require("typescript.extensions.null-ls.code-actions"))
    end,

    yamlls = {
        before_init = function(_, config)
            config.settings.yaml.schemas = require("schemastore").json.schemas()
        end,
        settings = {
            -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
            redhat = { telemetry = { enabled = false } },
            yaml = {
                completion = true,
                format = {
                    enable = true,
                    singleQuote = false,
                },
                hover = true,
                validate = true,
            },
        },
    },
}

return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            --
            -- Jump directly to the first available definition every time.
            -- Use Telescope if there is more than one result.
            vim.lsp.handlers["textDocument/definition"] = function(_, result, ctx)
                if not result or vim.tbl_isempty(result) then
                    vim.api.nvim_echo({ { "LSP: Could not find definition" } }, false, {})
                    return
                end

                local client = vim.lsp.get_client_by_id(ctx.client_id)

                if vim.tbl_islist(result) then
                    local results = vim.lsp.util.locations_to_items(result, client.offset_encoding)
                    local lnum, filename = results[1].lnum, results[1].filename

                    for _, val in pairs(results) do
                        if val.lnum ~= lnum or val.filename ~= filename then
                            return require("telescope.builtin").lsp_definitions()
                        end
                    end

                    vim.lsp.util.jump_to_location(result[1], client.offset_encoding, false)
                else
                    vim.lsp.util.jump_to_location(result, client.offset_encoding, true)
                end
            end

            require("lspconfig.ui.windows").default_options.border = vim.g.border

            vim.lsp.set_log_level(vim.log.levels.ERROR)

            vim.api.nvim_create_user_command("LspCapabilities", function()
                local curBuf = vim.api.nvim_get_current_buf()
                local clients = vim.lsp.get_active_clients({ bufnr = curBuf })

                for _, client in pairs(clients) do
                    if not vim.tbl_contains({ "copilot", "null-ls" }, client.name) then
                        local capAsList = {}
                        for key, value in pairs(client.server_capabilities) do
                            if value and key:find("Provider") then
                                local capability = key:gsub("Provider$", "")
                                table.insert(capAsList, "- " .. capability)
                            end
                        end

                        table.sort(capAsList) -- sorts alphabetically

                        local msg = "# " .. client.name .. "\n" .. table.concat(capAsList, "\n")

                        vim.notify(msg, vim.log.levels.INFO, {
                            on_open = function()
                                vim.api.nvim_set_option_value("filetype", "markdown", { scope = "local" })
                            end,
                            timeout = false,
                        })

                        vim.fn.setreg("+", "Capabilities = " .. vim.inspect(client.server_capabilities))
                    end
                end
            end, {})

            vim.keymap.set("n", "<leader>lc", vim.cmd.LspCapabilities, { desc = "  LSP Capabilities" })
            vim.keymap.set("n", "<leader>li", vim.cmd.LspInfo, { desc = "  LSP Info" })
            vim.keymap.set("n", "<leader>ll", vim.cmd.LspLog, { desc = " LSP Log" })
            vim.keymap.set("n", "<leader>lr", vim.cmd.LspRestart, { desc = "  LSP Restart" })
            vim.keymap.set("n", "<leader>ls", vim.cmd.LspStop, { desc = " LSP Stop" })

            -- Handle Swift. Let clangd handle C/C++
            if vim.g.os == "Darwin" then
                require("lspconfig").sourcekit.setup({
                    capabilities = common.capabilities(),
                    filetypes = { "objective-c", "objective-cpp", "swift" },
                    on_attach = common.on_attach,
                })
            end
        end,
        dependencies = {
            "folke/neodev.nvim",
            opts = {
                library = {
                    plugins = false,
                },
                setup_jsonls = false,
            },
        },
    },
    -- Mason related packages follow.
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        cmd = { "Mason", "MasonInstall", "MasonUninstall" },
        config = function()
            require("mason").setup({
                ui = {
                    border = vim.g.border,
                },
            })

            require("mason-registry"):on("package:install:success", require("plugins.lsp.python").mason_post_install)
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            local handlers = {}

            for name, handler in pairs(servers) do
                if type(handler) == "function" then
                    handlers[name] = handler
                else
                    handlers[name] = function()
                        require("lspconfig")[name].setup(vim.tbl_deep_extend("force", {
                            capabilities = common.capabilities(),
                            on_attach = common.on_attach,
                        }, handler))
                    end
                end
            end

            require("mason-lspconfig").setup({
                automatic_installation = true,
                ensure_installed = vim.tbl_keys(handlers),
                handlers = handlers,
            })
        end,
        event = { "BufReadPre", "BufNewFile" },
    },
    {
        "jay-babu/mason-null-ls.nvim",
        dependencies = { "mason.nvim", "null-ls.nvim" },
        event = "VeryLazy",
        opts = {
            automatic_installation = true,
        },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        cmd = {
            "MasonToolsInstall",
            "MasonToolsUpdate",
        },
        event = "VeryLazy",
        opts = {
            ensure_installed = { "gitui", "glow" },
            run_on_start = false,
        },
    },
    {
        "aznhe21/actions-preview.nvim",
        config = function()
            require("actions-preview").setup({
                diff = {
                    algorithm = "patience",
                    ignore_whitespace = true,
                },
                telescope = require("telescope.themes").get_dropdown({
                    layout_config = {
                        width = 0.75,
                        prompt_position = "bottom",
                    },
                }),
            })
        end,
    },
    { "b0o/schemastore.nvim", version = false },
    {
        "crispgm/nvim-go",
        cmd = {
            "GoFormat",
            "GoGet",
            "GoInstall",
            "GoLint",
        },
        event = "VeryLazy",
    },
    { "jose-elias-alvarez/typescript.nvim" },
    { "microsoft/python-type-stubs" },
    { "p00f/clangd_extensions.nvim" },
    { "MunifTanjim/rust-tools.nvim" },
    { "smjonas/inc-rename.nvim", config = true },
    { "yioneko/nvim-type-fmt", lazy = false }, -- LSP handler of textDocument/onTypeFormatting for nvim. Sets itself up via an LspAttach autocmd.
    { "VidocqH/lsp-lens.nvim", config = true, event = "LspAttach" },
    { "zbirenbaum/neodim", branch = "v2", config = true, event = "LspAttach" },
}
