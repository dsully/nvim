vim.lsp.config.gopls = {
    cmd = { "gopls" },
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
    root_markers = { "go.mod", "go.work" },
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
    single_file_support = true,
}
