local default_inlay_hint_handler = vim.lsp.handlers["textDocument/inlayHint"]

local function inlay_hint_label_text(label)
    if type(label) == "string" then
        return label
    end

    if type(label) == "table" then
        local parts = {}
        for _, part in ipairs(label) do
            if type(part) == "table" then
                parts[#parts + 1] = part.value or ""
            elseif type(part) == "string" then
                parts[#parts + 1] = part
            end
        end
        return table.concat(parts)
    end

    return ""
end

local function trim_trailing_space(s)
    return s:sub(1, -2)
end

local function trim_trailing_space_from_label(label)
    if type(label) == "string" then
        return trim_trailing_space(label)
    end

    if type(label) == "table" then
        for i = #label, 1, -1 do
            local part = label[i]
            if type(part) == "table" and type(part.value) == "string" then
                part.value = trim_trailing_space(part.value)
                break
            end
            if type(part) == "string" then
                label[i] = trim_trailing_space(part)
                break
            end
        end
    end

    return label
end

local function is_parameter_name_hint(hint)
    return inlay_hint_label_text(hint.label):match("=%s$") ~= nil
end

---@type vim.lsp.Config
return {
    cmd = { "pyrefly", "lsp" },
    filetypes = { "python" },
    root_markers = {
        "pyrefly.toml",
        "pyproject.toml",
        ".git",
    },
    ---@param client vim.lsp.Client
    on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd("LspTokenUpdate", {
            buffer = bufnr,
            callback = function(args)
                if args.data.client_id ~= client.id then
                    return
                end
                ---@module 'vim.lsp.semantic_tokens'
                ---@type STTokenRange
                local token = args.data.token
                if token.type == "property" then
                    return
                end
                if token.type == "interface" then
                    vim.lsp.semantic_tokens.highlight_token(token, args.buf, args.data.client_id, "@lsp.type.class.python")
                end
            end,
        })

        --
        -- Use treesitter highlighting, as it supports injections.
        if client.server_capabilities then
            client.server_capabilities.callHierarchyProvider = nil
            -- client.server_capabilities.codeActionProvider = nil
            client.server_capabilities.completionProvider = nil
            client.server_capabilities.declarationProvider = nil
            client.server_capabilities.definitionProvider = nil
            client.server_capabilities.documentHighlightProvider = nil
            client.server_capabilities.documentOnTypeFormattingProvider = nil
            client.server_capabilities.documentSymbolProvider = nil
            client.server_capabilities.executeCommandProvider = nil
            client.server_capabilities.hoverProvider = nil
            client.server_capabilities.inlayHintProvider = nil
            client.server_capabilities.implementationProvider = nil
            client.server_capabilities.notebookDocumentSync = nil
            client.server_capabilities.renameProvider = nil

            client.server_capabilities.referencesProvider = nil
            client.server_capabilities.semanticTokensProvider = nil
            client.server_capabilities.signatureHelpProvider = nil
            client.server_capabilities.typeDefinitionProvider = nil
            client.server_capabilities.workspaceSymbolProvider = nil
        end
    end,
    on_exit = function(code, _, _)
        vim.notify("Closing Pyrefly LSP exited with code: " .. code, vim.log.levels.INFO)
    end,
    ---@type table<vim.lsp.protocol.Methods, lsp.Handler>
    handlers = {
        ["textDocument/inlayHint"] = function(err, result, ctx, config)
            if err or type(result) ~= "table" then
                return default_inlay_hint_handler(err, result, ctx, config)
            end

            local filtered = {}
            for _, hint in ipairs(result) do
                local label_text = inlay_hint_label_text(hint.label)
                local ignore = vim.startswith(label_text, "_")

                if not ignore then
                    if is_parameter_name_hint(hint) then
                        hint.label = trim_trailing_space_from_label(hint.label)
                    end
                    filtered[#filtered + 1] = hint
                end
            end

            return default_inlay_hint_handler(err, filtered, ctx, config)
        end,
    },
    settings = {
        python = {
            pyrefly = {
                displayTypeErrors = "force-on",
                -- TODO: pending feature https://github.com/facebook/pyrefly/commit/74787015787ea28da79b4d0f617cfb82ce4c66f7
                -- diagnosticMode = 'workspace',
                analysis = {
                    inlayHints = {
                        callArgumentNames = "all",
                        variableTypes = true,
                        functionReturnTypes = true,
                        pytestParameters = true,
                    },
                },
            },
        },
    },
}
