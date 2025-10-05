---@type vim.lsp.Config
return {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        --
        -- Use treesitter highlighting, as it supports injections.
        if client.server_capabilities then
            -- client.server_capabilities.callHierarchyProvider = nil
            -- -- client.server_capabilities.codeActionProvider = nil
            -- -- client.server_capabilities.completionProvider = nil
            -- -- client.server_capabilities.declarationProvider = nil
            -- -- client.server_capabilities.definitionProvider = nil
            -- -- client.server_capabilities.documentHighlightProvider = nil
            client.server_capabilities.documentOnTypeFormattingProvider = nil
            -- client.server_capabilities.documentSymbolProvider = nil
            -- client.server_capabilities.executeCommandProvider = nil
            -- -- client.server_capabilities.hoverProvider = nil
            -- client.server_capabilities.inlayHintProvider = nil
            -- client.server_capabilities.notebookDocumentSync = nil
            -- -- client.server_capabilities.referencesProvider = nil
            -- client.server_capabilities.renameProvider = nil
            -- client.server_capabilities.semanticTokensProvider = nil
            -- client.server_capabilities.signatureHelpProvider = nil
            -- client.server_capabilities.typeDefinitionProvider = nil
            -- client.server_capabilities.workspaceSymbolProvider = nil
        end
    end,
    -- root_dir = function(_bufnr, _on_dir)
    --     --
    -- end,
    root_markers = {
        "Pipfile",
        "pyproject.toml",
        "pyrightconfig.json",
        "requirements.txt",
        "setup.cfg",
        "setup.py",
    },
    settings = {
        basedpyright = {
            analysis = {
                autoImportCompletions = true,
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                diagnosticSeverityOverrides = {
                    reportAny = false,
                    reportDeprecated = false,
                    reportExplicitAny = false,
                    -- reportImplicitStringConcatenation = false,
                    -- reportMissingParameterType = false,
                    -- reportMissingTypeArgument = false,
                    reportMissingTypeStubs = false,
                    reportOptionalMemberAccess = false,
                    reportAssignmentType = false,
                    reportAttributeAccessIssue = false,
                    -- reportUnannotatedClassAttribute = false,
                    -- reportUninitializedInstanceVariable = false,
                    -- reportUnknownArgumentType = false,
                    -- reportUnknownMemberType = false,
                    -- reportUnknownParameterType = false,
                    -- reportUnknownVariableType = false,
                    -- reportUnnecessaryComparison = false,
                    -- reportUnnecessaryIsInstance = false,
                    reportUnreachable = false,
                    reportUnusedCallResult = false,
                    reportUnusedFunction = false,
                    reportUnusedImport = false,
                    -- reportUnusedParameter = false,
                },
                -- exclude = { "crt" },
                -- ignore = { ".venv" },
                logLevel = "error",
                typeCheckingMode = "basic",
                useLibraryCodeForTypes = true,
            },
            disableOrganizeImports = true,
        },
    },
    single_file_support = true,
}
