local M = {}
local defaults = require("config.defaults")

---@class LspClientBuffers
---@field client vim.lsp.Client
---@field buffers integer[]

---Get a LSP client by ID, optionally filtering on method.
---@param id integer
---@param method string?
---@return vim.lsp.Client?
M.client_by_id = function(id, method)
    --
    local client = vim.lsp.get_client_by_id(id)

    if not client or M.should_ignore(client) then
        return
    end

    if method and not client.supports_method(method) then
        return
    end

    return client
end

---Get a LSP client by name.
---@param name string
---@return vim.lsp.Client?
M.client_by_name = function(name)
    --
    local clients = vim.lsp.get_clients({ name = name })

    if #clients == 0 then
        return
    end

    return clients[1]
end

---Return false if the buffer or client is ignored.
---@param client vim.lsp.Client?
---@return boolean
M.should_ignore = function(client)
    --
    -- Skip ignored file types and buffer types.
    if defaults.ignored.file_types[vim.bo.filetype] or defaults.ignored.buffer_types[vim.bo.buftype] then
        return true
    end

    if client and defaults.ignored.lsp[client.name] then
        return true
    end

    return false
end

---@param filter? vim.lsp.get_clients.Filter
---@return LspClientBuffers[]
M.buffers_for_client = function(filter)
    --
    ---@type LspClientBuffers[]
    local mapping = {}

    for _, client in ipairs(vim.lsp.get_clients(filter)) do
        --
        if not M.should_ignore(client) then
            mapping[client] = vim.tbl_extend("force", mapping[client], vim.lsp.get_buffers_by_client_id(client.id))
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

return M
