local M = {}

local methods = vim.lsp.protocol.Methods

---@alias LspClientBuffers table<vim.lsp.Client, integer[]>

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
---@return LspClientBuffers
M.buffers_for_client = function(filter)
    --
    ---@type LspClientBuffers
    local mapping = {}

    for _, client in ipairs(vim.lsp.get_clients(filter)) do
        --
        if not M.should_ignore(client) then
            mapping[client] = vim.tbl_extend("force", mapping[client] or {}, vim.lsp.get_buffers_by_client_id(client.id))
        end
    end

    return mapping
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
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        if client and not M.should_ignore(client) then
            return on_attach(client, buffer)
        end
    end)
end

---@param fn fun(client:vim.lsp.Client, buffer):boolean?
function M.on_dynamic_capability(fn)
    --
    return ev.on(ev.User, function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buffer = args.data.buffer ---@type number

        if client then
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
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buffer = args.data.buffer ---@type number

        if client and method == args.data.method then
            return fn(client, buffer)
        end
    end, {
        pattern = ev.LspSupportsMethod,
    })
end

M.code_action = function()
    ---@type vim.lsp.buf.code_action.Opts
    vim.lsp.buf.code_action({
        context = {
            diagnostics = {},
            only = defaults.code_actions,
        },
    })
end

M.apply_quickfix = function()
    vim.lsp.buf.code_action({
        apply = true,
        context = {
            diagnostics = {},
            only = defaults.code_actions,
        },
        ---@param action lsp.CodeAction|lsp.Command
        filter = function(action)
            return action.isPreferred and action.isPreferred or action.kind == vim.lsp.protocol.CodeActionKind.QuickFix
        end,
    })
end

M.commands = function()
    nvim.command("LspCapabilities", function()
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

        ---@diagnostic disable-next-line param-type-not-match
        vim.ui.float({ ft = "lua", relative = "editor" }, lines):show()
    end, { desc = "Show LSP Capabilities" })

    nvim.command("LspCodeActions", function()
        --
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = {}

        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, method = methods.textDocument_codeAction })) do
            local name = client and client.name or ""

            local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
            params.context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() }

            client:request(methods.textDocument_codeAction, params, function(_, result)
                if not vim.tbl_contains(defaults.ignored.lsp, name) and result.result then
                    --
                    table.insert(lines, name .. " Code Actions:")
                    table.insert(lines, "")

                    for _, code_action in pairs(result.result or {}) do
                        --
                        ---@cast code_action lsp.CodeAction
                        if code_action.title then
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
        vim.cmd.tabnew(vim.lsp.get_log_path())
    end, {
        desc = "Opens the Nvim LSP client log.",
    })

    nvim.command("LspRestartBuffer", function()
        --
        M.apply_to_buffers(function(bufnr, client)
            --

            if client then
                vim.lsp.stop_client(client.id, true)

                notify.info(("Restarting LSP %s for %s"):format(client.name, vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))))
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
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    local lines = {
        "Language Server Log: " .. vim.lsp.get_log_path(),
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
