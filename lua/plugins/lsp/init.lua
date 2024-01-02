require("plugins.lsp.handlers")

local common = require("plugins.lsp.common")

local servers = {
    bashls = {
        filetypes = { "bash", "sh", "zsh" },
    },
    -- https://github.com/biomejs/biome
    biome = {
        cmd = { "biome", "lsp-proxy", "--config-path", vim.env.XDG_CONFIG_HOME },
    },
    bufls = {},
    bzl = {},
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
    clangd = {
        capabilities = vim.tbl_extend("force", common.capabilities(), {
            textDocument = {
                completion = {
                    editsNearCursor = true,
                },
            },
            offsetEncoding = { "utf-16" },
        }),
        cmd = {
            "clangd",
            "--all-scopes-completion",
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--fallback-style=llvm",
            "--function-arg-placeholders",
            "--header-insertion=iwyu",
        },
        -- Don't want objective-c and objective-cpp.
        filetypes = { "c", "cpp", "cuda" },
        init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
        },
        on_attach = function(client, ...)
            -- https://github.com/p00f/clangd_extensions.nvim
            require("clangd_extensions").setup()

            local inlay_hints = require("clangd_extensions.inlay_hints")

            inlay_hints.setup_autocmd()
            inlay_hints.set_inlay_hints()
            inlay_hints.toggle_inlay_hints()

            common.on_attach(client, ...)
        end,
        root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
                "Makefile",
                "configure.ac",
                "configure.in",
                "config.h.in",
                "meson.build",
                "meson_options.txt",
                "build.ninja"
            )(fname) or require("lspconfig.util").find_git_ancestor(fname)
        end,
    },
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
                directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
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
    gradle_ls = {
        on_attach = function(client, ...)
            common.on_attach(client, ...)
            vim.lsp.handlers["textDocument/references"] = nil
        end,
    },
    jsonls = {
        before_init = function(_, config)
            vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
        end,
        filetypes = { "json", "jsonc" },
        settings = {
            json = {
                schemas = {},
                validate = { enable = true },
            },
        },
    },
    jedi_language_server = {
        on_attach = function(client, ...)
            -- Let ruff handle code actions.
            client.server_capabilities.codeActionProvider = false
            common.on_attach(client, ...)
        end,
        root_dir = function(fname)
            return require("lspconfig.util").root_pattern("pyproject.toml", "setup.cfg", "setup.py")(fname)
        end,
    },
    lua_ls = {
        settings = {
            Lua = {
                completion = {
                    callSnippet = "Replace",
                    keywordSnippet = "Both",
                    workspaceWord = true,
                },
                diagnostics = {
                    -- Have the language server to recognize the `vim` global.
                    globals = { "bit", "vim" },
                },
                doc = {
                    privateName = { "^_" },
                },
                format = {
                    enable = false,
                },
                hint = {
                    arrayIndex = "Disable",
                    enable = true,
                    paramName = "Disable",
                    paramType = true,
                    semicolon = "Disable",
                    setType = true,
                },
                runtime = {
                    version = "Lua 5.1",
                },
                telemetry = {
                    enable = false,
                },
                type = {
                    castNumberToInteger = true,
                },
                workspace = {
                    checkThirdParty = false,
                },
            },
        },
    },
    pyright = {
        on_attach = function(client, ...)
            -- Let jedi or ruff handle these.
            client.server_capabilities.codeActionProvider = false
            client.server_capabilities.completionProvider = false
            client.server_capabilities.declarationProvider = false
            client.server_capabilities.definitionProvider = false
            client.server_capabilities.documentSymbolProvider = false
            client.server_capabilities.hoverProvider = false
            client.server_capabilities.referencesProvider = false
            client.server_capabilities.signatureHelpProvider = false
            common.on_attach(client, ...)
        end,
    },
    ruff_lsp = function()
        require("lspconfig").ruff_lsp.setup({
            capabilities = common.capabilities(),
            filetypes = { "python", "toml.pyproject" },
            init_options = {
                settings = {
                    format = {
                        args = require("plugins.lsp.python").ruff_format_args(),
                    },
                    lint = {
                        args = require("plugins.lsp.python").ruff_check_args(),
                    },
                },
            },
            on_attach = function(client, bufnr, ...)
                local request = function(method, params)
                    client.request(method, params, nil, bufnr)
                end

                vim.api.nvim_create_user_command("RuffAutoFix", function()
                    request("workspace/executeCommand", {
                        command = "ruff.applyAutofix",
                        arguments = {
                            { uri = vim.uri_from_bufnr(bufnr) },
                        },
                    })
                end, { desc = "Ruff: Fix all auto-fixable problems" })

                vim.api.nvim_create_user_command("RuffOrganizeImports", function()
                    request("workspace/executeCommand", {
                        command = "ruff.applyOrganizeImports",
                        arguments = {
                            { uri = vim.uri_from_bufnr(bufnr) },
                        },
                    })
                end, { desc = "Ruff: Organize Imports" })

                client.server_capabilities.hoverProvider = false
                common.on_attach(client, ...)
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
        })
    end,

    rust_analyzer = {
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
                checkOnSave = {
                    command = "clippy",
                },
                completion = {
                    postfix = {
                        enable = true,
                    },
                    callable = {
                        -- Whether to add parenthesis and argument snippets when completing function.
                        -- Possible value: fill_arguments (default), add_parentheses, none
                        snippets = "fill_arguments",
                    },
                    snippets = {
                        custom = {
                            ["println!"] = {
                                ["postfix"] = "println",
                                ["body"] = {
                                    'println!("$0", ${receiver});',
                                },
                                ["description"] = "println!()",
                                ["scope"] = "expr",
                            },
                            Ok = {
                                postfix = "ok",
                                body = "Ok(${receiver})",
                                description = "Wrap the expression in a `Result::Ok`",
                                scope = "expr",
                            },
                            Err = {
                                postfix = "err",
                                body = "Err(${receiver})",
                                description = "Wrap the expression in a `Result::Err`",
                                scope = "expr",
                            },
                            Some = {
                                ["postfix"] = "some",
                                ["body"] = "Some(${receiver})",
                                ["description"] = "Wrap the expression in an `Option::Some`",
                                ["scope"] = "expr",
                            },
                        },
                    },
                },
                -- https://github.com/rust-analyzer/rust-analyzer/issues/6835
                diagnostics = {
                    disabled = { "inactive-code", "macro-error", "unresolved-macro-call" },
                    experimental = { enable = true },
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
                inlayHints = {
                    chainingHints = { enable = false },

                    -- Whether to show inlay hints for closure captures.
                    -- https://rust-analyzer.github.io//thisweek/2023/05/15/changelog-181.html#new-features
                    closureCaptureHints = { enable = false }, -- default : false

                    -- Whether to show inlay type hints for return types of closures.
                    closureReturnTypeHints = { enable = "with_block" }, --default: "never", options: "always", "never", "with_block"

                    parameterHints = { enable = false },
                },
                lru = { capacity = 2048 },
                procMacro = { enable = true },
                references = {
                    -- Exclude imports from find-all-references.
                    excludeImports = true,
                },
                workspace = {
                    symbol = {
                        search = {
                            kind = "all_symbols",
                            scope = "workspace_and_dependencies",
                        },
                    },
                },
            },
        },
        standalone = false,
    },

    taplo = {
        filetypes = { "toml", "toml.pyproject" },
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
        require("typescript-tools").setup({
            capabilities = common.capabilities(),
            on_attach = common.on_attach,
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
        })
    end,

    yamlls = function()
        require("lspconfig").yamlls.setup(require("yaml-companion").setup({
            builtin_matchers = {
                cloud_init = { enabled = false },
                kubernetes = { enabled = false },
            },
            lspconfig = {
                capabilities = vim.tbl_extend("force", common.capabilities(), {
                    textDocument = {
                        foldingRange = {
                            dynamicRegistration = false,
                            lineFoldingOnly = true,
                        },
                    },
                }),
                filetypes = { "yaml", "yaml.ghaction", "!yaml.ansible" },
                on_attach = common.on_attach,
                on_new_config = function(config)
                    vim.list_extend(config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
                end,
                settings = {
                    yaml = {
                        format = {
                            singleQuote = false,
                        },
                    },
                },
            },
        }))
    end,
}

return {
    {
        "neovim/nvim-lspconfig",
        cmd = {
            "Mason",
            "MasonInstall",
            "MasonUninstall",
            "MasonToolsInstall",
            "MasonToolsUpdate",
        },
        config = function()
            require("lspconfig.ui.windows").default_options.border = vim.g.border
            require("neoconf").setup()

            vim.lsp.set_log_level(vim.log.levels.ERROR)

            vim.api.nvim_create_user_command("LspCapabilities", function()
                local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
                local lines = {}

                for i, client in pairs(clients) do
                    if not vim.tbl_contains({ require("config.defaults").ignored.lsp }, client.name) then
                        table.insert(lines, "# " .. client.name:upper())
                        table.insert(lines, "```lua")

                        for s in vim.inspect(client.server_capabilities):gmatch("[^\r\n]+") do
                            table.insert(lines, s)
                        end

                        table.insert(lines, "```")

                        if i < #clients then
                            table.insert(lines, "")
                        end
                    end
                end

                require("helpers.float").open(lines)
            end, { desc = "Show LSP Capabilities" })

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

            local mason_tools = {
                "codelldb",
                "gitui",
                "glow",
                "jdtls",
                "write-good",
            }

            -- Pull in linters and formatters.
            for _, f in pairs(require("config.defaults").formatters) do
                table.insert(mason_tools, f.command)
            end

            for _, f in pairs(require("lint").linters_by_ft) do
                mason_tools = vim.tbl_extend("force", mason_tools, f)
            end

            -- Remove built-ins / formatters that are not in Mason.
            --
            -- 'typos-cli' doesn't have a pre-compiled release for Apple Silicon.
            mason_tools = vim.tbl_filter(function(t)
                return not vim.tbl_contains({ "caddy", "fish", "fish_indent", "just", "typos", "write_good" }, t)
            end, mason_tools)

            -- Require before mason itself is loaded.
            require("plugins.lsp.mason")

            require("mason").setup({
                registries = {
                    "lua:plugins.lsp.mason",
                    "github:mason-org/mason-registry",
                },
                ui = {
                    border = vim.g.border,
                },
            })

            require("mason-lspconfig").setup({
                automatic_installation = true,
                ensure_installed = vim.tbl_keys(handlers),
                handlers = handlers,
            })

            require("mason-tool-installer").setup({
                auto_update = false,
                debounce_hours = 0,
                ensure_installed = mason_tools,
                run_on_start = false,
                start_delay = 2000,
            })
        end,
        dependencies = {
            {
                "folke/neodev.nvim",
                opts = {
                    library = {
                        plugins = false,
                    },
                    setup_jsonls = false,
                },
            },
            { "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
            { "williamboman/mason-lspconfig.nvim" },
            { "williamboman/mason.nvim", build = ":MasonUpdate" },
            { "WhoIsSethDaniel/mason-tool-installer.nvim" },
        },
        event = vim.g.defaults.lazyfile,
    },
    {
        "aznhe21/actions-preview.nvim",
        config = function()
            require("actions-preview").setup({
                backend = { "nui" },
                diff = {
                    algorithm = "patience",
                    ignore_whitespace = true,
                },
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
        enabled = false,
        event = "VeryLazy",
    },
    { "microsoft/python-type-stubs" },
    { "p00f/clangd_extensions.nvim" },
    { "pmizio/typescript-tools.nvim" },
    { "smjonas/inc-rename.nvim", opts = {} },
    { "someone-stole-my-name/yaml-companion.nvim" },
    { "VidocqH/lsp-lens.nvim", event = "LspAttach", opts = {} },
    { "zbirenbaum/neodim", event = "LspAttach", opts = {} },

    -- Load Lua plugin files without needing to have them in the LSP workspace.
    { "mrjones2014/lua-gf.nvim", event = "VeryLazy", ft = "lua" },

    -- Display diagnostic inline
    {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        config = function()
            local default_virtual_text = vim.diagnostic.config().virtual_text

            vim.diagnostic.config({
                virtual_lines = false,
                virtual_text = default_virtual_text,
            })

            vim.keymap.set("n", "<localleader>l", function()
                local new_value = not vim.diagnostic.config().virtual_lines

                --- @type boolean|table
                local virtual_text = default_virtual_text

                if new_value then
                    virtual_text = false
                end

                vim.diagnostic.config({
                    virtual_lines = new_value,
                    virtual_text = virtual_text,
                })
            end, { buffer = true, desc = "Toggle LSP Diagnostic Lines" })

            require("lsp_lines").setup({})
        end,
        event = "LspAttach",
    },
    {
        "chrisgrieser/nvim-rulebook",
        keys = {
            {
                "<leader>di",
                function()
                    require("telescope")
                    require("rulebook").ignoreRule()
                end,
                desc = "  Ignore Rule",
            },
            {
                "<leader>dl",
                function()
                    require("telescope")
                    require("rulebook").lookupRule()
                end,
                desc = "  Look up Rule",
            },
        },
    },
}
