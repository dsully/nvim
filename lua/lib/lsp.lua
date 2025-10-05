local M = {}

local code_actions = {
    "",
    "quickfix",
    -- "refactor",
    -- "refactor.extract",
    -- "refactor.inline",
    "refactor.rewrite",
    "source",
    "source.fixAll",
    "source.organizeImports",
}

---@class LspClientBuffers
---@field client vim.lsp.Client
---@field buffers integer[]

---Return false if the server should be disabled.
--
---@param server_name string
---@return boolean
M.should_enable = function(server_name)
    local is_local = nvim.file.is_local_dev()

    if vim.tbl_contains(defaults.ignored.lsp, server_name) or not is_local then
        return false
    end

    return true
end

---Return false if the buffer or client is ignored.
---@param client vim.lsp.Client?
---@return boolean
M.should_ignore = function(client)
    --
    -- Skip ignored file types and buffer types.
    if vim.tbl_contains(defaults.ignored.file_types, vim.bo.filetype) or vim.tbl_contains(defaults.ignored.buffer_types, vim.bo.buftype) then
        return true
    end

    if client and vim.tbl_contains(defaults.ignored.lsp, client.name) then
        return true
    end

    return false
end

---@param filter? vim.lsp.get_clients.Filter
---@return LspClientBuffers[]
M.buffers_for_client = function(filter)
    local clients = {}

    for _, client in
        ipairs(vim.lsp.get_clients(filter) --[[@as vim.lsp.Client[] ]])
    do
        if not M.should_ignore(client) then
            local buffers = vim.lsp.get_buffers_by_client_id(client.id)

            if #buffers > 0 then
                clients[#clients + 1] = {
                    client = client,
                    buffers = buffers,
                }
            end
        end
    end

    return clients
end

---@param callback fun(buf: integer, client: vim.lsp.Client?)
---@param filter? vim.lsp.get_clients.Filter
M.apply_to_buffers = function(callback, filter)
    --
    for _, m in ipairs(M.buffers_for_client(filter)) do
        for _, buf in ipairs(m.buffers) do
            callback(buf, m.client)
        end
    end
end

-- Handle code actions.
M.action = setmetatable({}, {
    __index = function(_, action)
        return function()
            vim.lsp.buf.code_action({
                apply = true,
                context = {
                    only = { action },
                    diagnostics = {},
                },
            })
        end
    end,
})

---@type table<string, table<vim.lsp.Client, table<number, boolean>>>
M.supports_method = {}

---@param client vim.lsp.Client
---@param buffer integer
M.validate_client = function(client, buffer)
    if not vim.api.nvim_buf_is_valid(buffer) then
        return
    end

    if not vim.bo[buffer].buflisted then
        return
    end

    if vim.bo[buffer].buftype == "nofile" then
        return
    end

    for method, clients in pairs(M.supports_method) do
        clients[client] = clients[client] or {}

        if not clients[client][buffer] then
            --
            if
                client:supports_method(method --[[@as vim.lsp.protocol.Method.ClientToServer]], buffer)
            then
                clients[client][buffer] = true

                ev.emit(ev.User, {
                    pattern = ev.LspSupportsMethod,
                    data = { client_id = client.id, buffer = buffer, method = method },
                })
            end
        end
    end
end

---@param on_attach fun(client:vim.lsp.Client, buffer)
function M.on_attach(on_attach)
    --
    ev.on(ev.LspAttach, function(args)
        local buffer = args.buf ---@type integer

        local client = vim.lsp.get_client_by_id(args.data.client_id) --[[@as vim.lsp.Client]]

        if client and not M.should_ignore(client) then
            return on_attach(client, buffer)
        end
    end)
end

---@param fn fun(client:vim.lsp.Client, buffer):boolean?
function M.on_dynamic_capability(fn)
    --
    return ev.on(ev.User, function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id) --[[@as vim.lsp.Client]]

        local buffer = args.data.buffer ---@type number

        if client ~= nil then
            return fn(client, buffer)
        end
    end, {
        pattern = ev.LspDynamicCapability,
    })
end

---@param method string
---@param fn fun(client:vim.lsp.Client, buffer)
function M.on_supports_method(method, fn)
    M.supports_method[method] = M.supports_method[method] or setmetatable({}, { __mode = "k" })

    return ev.on(ev.User, function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id) --[[@as vim.lsp.Client]]
        local buffer = args.data.buffer ---@type number

        if client and method == args.data.method then
            return fn(client, buffer)
        end
    end, {
        pattern = ev.LspSupportsMethod,
    })
end

M.code_action = function()
    vim.lsp.buf.code_action({
        context = {
            diagnostics = {},
            only = code_actions,
        },
    })
end

M.apply_quickfix = function()
    vim.lsp.buf.code_action({
        apply = true,
        context = {
            diagnostics = {},
            only = code_actions,
        },
        ---@param action lsp.CodeAction|lsp.Command
        filter = function(action)
            return action.isPreferred and action.isPreferred or action.kind == vim.lsp.protocol.CodeActionKind.QuickFix
        end,
    })
end

local function get_capability_display_name(key)
    local capability_names = {
        completionProvider = "Completion Provider",
        hoverProvider = "Hover Provider",
        signatureHelpProvider = "Signature Help Provider",
        diagnosticProvider = "Diagnostic Provider",
        documentFormattingProvider = "Document Formatting Provider",
        documentRangeFormattingProvider = "Document Range Formatting Provider",
        codeActionProvider = "Code Action Provider",
        documentSymbolProvider = "Document Symbol Provider",
        workspaceSymbolProvider = "Workspace Symbol Provider",
        definitionProvider = "Definition Provider",
        declarationProvider = "Declaration Provider",
        implementationProvider = "Implementation Provider",
        typeDefinitionProvider = "Type Definition Provider",
        referencesProvider = "References Provider",
        renameProvider = "Rename Provider",
        inlayHintProvider = "Inlay Hint Provider",
        semanticTokensProvider = "Semantic Tokens Provider",
        executeCommandProvider = "Execute Command Provider",
        textDocumentSync = "Text Document Sync",
        workspace = "Workspace Features",
        selectionRangeProvider = "Selection Range Provider",
        documentHighlightProvider = "Document Highlight Provider",
        positionEncoding = "Position Encoding",
    }
    return capability_names[key] or key
end

local function extract_capabilities(clients)
    local capabilities = {}

    for _, client in ipairs(clients) do
        if not vim.tbl_contains(defaults.ignored.lsp, client.name) then
            for key, value in pairs(client.server_capabilities) do
                if value ~= nil and value ~= false then
                    capabilities[key] = capabilities[key] or {}
                    capabilities[key][client.name] = value
                end
            end
        end
    end

    return capabilities
end

local function format_capability_value(value, key)
    if type(value) == "boolean" and value then
        return "enabled"
    elseif type(value) == "table" then
        local parts = {}
        for k, v in pairs(value) do
            -- Skip unwanted details
            if k == "workDoneProgress" or k == "prepareProvider" or k == "interFileDependencies" or (k == "workspaceDiagnostics" and v == false) then
                goto continue
            end

            -- Skip semantic token details (legend, full, range)
            if key == "semanticTokensProvider" and (k == "legend" or k == "full" or k == "range") then
                goto continue
            end

            if type(v) == "table" then
                if k == "commands" then
                    -- Return special marker for multiline handling
                    return { type = "commands", values = v }
                elseif k == "codeActionKinds" then
                    -- Return special marker for multiline handling
                    return { type = "kinds", values = v }
                else
                    table.insert(parts, k .. " = " .. vim.inspect(v, { indent = "", newline = " " }))
                end
            else
                table.insert(parts, k .. " = " .. tostring(v))
            end
            ::continue::
        end

        if #parts == 0 then
            return "enabled"
        end
        return table.concat(parts, ", ")
    else
        return tostring(value)
    end
end

M.commands = function()
    nvim.command("LspCapabilities", function()
        --
        local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() }) --[[@as vim.lsp.Client[] ]]

        local lines = {}

        -- Filter out ignored clients
        local active_clients = {}
        for _, client in ipairs(clients) do
            if not vim.tbl_contains(defaults.ignored.lsp, client.name) then
                table.insert(active_clients, client.name)
            end
        end

        if #active_clients == 0 then
            table.insert(lines, "No active LSP clients")
            ---@diagnostic disable-next-line param-type-not-match
            vim.ui.float({ ft = "lua", relative = "editor" }, lines):show()
            return
        end

        -- Header with active clients
        table.insert(lines, "Active LSP Servers: " .. table.concat(active_clients, ", "))
        table.insert(lines, "")
        table.insert(lines, "=== CAPABILITIES BY TYPE ===")
        table.insert(lines, "")

        -- Group capabilities by type
        local capabilities = extract_capabilities(clients)

        -- Sort capability keys for consistent output
        local sorted_keys = {}
        for key in pairs(capabilities) do
            table.insert(sorted_keys, key)
        end
        table.sort(sorted_keys)

        for _, key in ipairs(sorted_keys) do
            -- Skip certain capabilities
            if key == "positionEncoding" or key == "workspace" or key == "textDocumentSync" then
                goto continue
            end

            local providers = capabilities[key]
            local display_name = get_capability_display_name(key)

            table.insert(lines, display_name .. ":")

            -- Sort LSP names for consistent output
            local sorted_lsps = {}
            for lsp_name in pairs(providers) do
                table.insert(sorted_lsps, lsp_name)
            end
            table.sort(sorted_lsps)

            for _, lsp_name in ipairs(sorted_lsps) do
                local value = providers[lsp_name]
                local formatted_value = format_capability_value(value, key)

                if formatted_value == "enabled" then
                    table.insert(lines, "  • " .. lsp_name)
                elseif type(formatted_value) == "table" then
                    -- Handle multiline formatting
                    if formatted_value.type == "commands" then
                        table.insert(lines, "  • " .. lsp_name .. ": commands:")
                        for _, cmd in ipairs(formatted_value.values) do
                            table.insert(lines, "      " .. cmd)
                        end
                    elseif formatted_value.type == "kinds" then
                        table.insert(lines, "  • " .. lsp_name .. ": kinds:")
                        for _, kind in ipairs(formatted_value.values) do
                            table.insert(lines, "      " .. kind)
                        end
                    end
                else
                    table.insert(lines, "  • " .. lsp_name .. ": " .. formatted_value)
                end
            end
            table.insert(lines, "")
            ::continue::
        end

        -- Configuration section
        table.insert(lines, "=== CONFIGURATIONS ===")
        table.insert(lines, "")

        for i, client in ipairs(clients) do
            if not vim.tbl_contains(defaults.ignored.lsp, client.name) and client.config.settings then
                table.insert(lines, client.name .. " Config:")
                table.insert(lines, "")

                for s in vim.inspect(client.config.settings):gmatch("[^\r\n]+") do
                    table.insert(lines, s)
                end

                if i < #clients then
                    table.insert(lines, "")
                end
            end
        end

        ---@diagnostic disable-next-line param-type-not-match
        vim.ui.float({ ft = "lua", relative = "editor" }, lines):show()
    end, { desc = "Show LSP Capabilities" })

    nvim.command("LspCodeActions", function()
        --
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = {}

        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/codeAction" })) do
            local name = client and client.name or ""

            local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
            params.context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() }

            client:request("textDocument/codeAction", params, function(_, result)
                if not vim.tbl_contains(defaults.ignored.lsp, name) and result.result ~= nil then
                    --
                    table.insert(lines, name .. " Code Actions:")
                    table.insert(lines, "")

                    for _, code_action in pairs(result.result or {}) do
                        --
                        ---@cast code_action lsp.CodeAction
                        if code_action ~= nil and code_action.title then
                            table.insert(lines, "Title: " .. code_action.title)
                            table.insert(lines, "Kind: " .. code_action.kind)
                            table.insert(lines, "Preferred: " .. tostring(code_action.isPreferred))
                            table.insert(lines, "")
                        end
                    end
                end
            end, bufnr)
        end

        if #lines == 0 then
            table.insert(lines, "No code actions available")
        end

        ---@diagnostic disable-next-line param-type-not-match
        vim.ui.float({ ft = "lua", relative = "editor" }, lines):show()
    end, { desc = "Show LSP Code Actions" })

    nvim.command("LspLog", function()
        vim.cmd.tabnew(vim.lsp.log.get_filename())
    end, {
        desc = "Opens the Nvim LSP client log.",
    })

    nvim.command("LspRestartBuffer", function()
        --
        M.apply_to_buffers(function(bufnr, client)
            --
            if client then
                vim.lsp.stop_client(client.id, true)

                Snacks.notify.info(("Restarting LSP %s for %s"):format(client.name, nvim.file.filename(bufnr)))
            end
        end, { bufnr = vim.api.nvim_get_current_buf() })

        vim.cmd.edit()
    end, { desc = "Restart Language Server for Buffer" })
end

---@param f fun(cfg: table):any
---@param cfg table
M.with = function(f, cfg)
    --
    ---@param c table
    return function(c)
        return f(vim.tbl_deep_extend("force", cfg, c or {}))
    end
end

M.info = function()
    ---@param client vim.lsp.Client
    ---@param config vim.lsp.Config
    ---@return string
    local function client_command(client, config)
        local cmd = config.cmd or client.config.cmd

        if type(cmd) == "table" then
            return table.concat(cmd, " ")
        elseif type(cmd) == "function" then
            --
            local info = debug.getinfo(cmd, "S")

            return ("<function %s:%s>"):format(info.source, info.linedefined)
        else
            return tostring(config.cmd)
        end
    end

    ---@param word string
    ---@param items table
    ---@return string
    local function pluralize(word, items)
        return #items == 1 and word or word .. "s"
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr }) --[[@as vim.lsp.Client[] ]]

    local lines = {
        "Language Server Log: " .. vim.lsp.log.get_filename(),
        "Detected filetype  : " .. vim.bo[bufnr].filetype,
        "",
        string.format("%s %s attached to this buffer:", tostring(#clients), pluralize("client", clients)),
    }

    for _, client in ipairs(clients) do
        ---@type vim.lsp.Config
        local config = vim.lsp.config[client.name] or {}

        local buffers = vim.iter(pairs(client.attached_buffers)):map(tostring):join(", ")

        vim.list_extend(lines, {
            "",
            string.format("%s (id: %s) %s: %s", client.name, client.id, pluralize("buffer", client.attached_buffers), buffers),
            "",
            "  - command: " .. client_command(client, config),
        })

        if client.workspace_folders and #client.workspace_folders > 1 then
            --
            vim.list_extend(lines, {
                "  - paths  : ",
            })

            for _, dir in ipairs(client.workspace_folders) do
                vim.list_extend(lines, { "            -" .. dir.name })
            end
        elseif client.root_dir then
            --
            vim.list_extend(lines, {
                "  - path   : " .. vim.fs.relpath("~", client.root_dir) or client.root_dir,
            })
        end

        if config.filetypes then
            vim.list_extend(lines, { "  - types  : " .. table.concat(config.filetypes, ", ") })
        end
    end

    ---@diagnostic disable-next-line param-type-not-match
    vim.ui.float({ ft = "lua", relative = "editor" }, lines):show()
end

return M
