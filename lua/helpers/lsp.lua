local M = {}
local defaults = require("config.defaults")

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

---Return false if the buffer or client is ignored.
---@param client vim.lsp.Client?
---@return boolean
M.should_ignore = function(client)
    --
    -- Skip ignored file types and buffer types.
    if defaults.ignored.file_types[vim.bo.filetype] or defaults.ignored.buffer_types[vim.bo.buftype] then
        return false
    end

    if client and defaults.ignored.lsp[client.name] then
        return false
    end

    return true
end

---@param id integer?
---@param method string?
---@return integer[]
M.buffers_for_client = function(id, method)
    --
    ---@type integer[]
    local buffers = {}

    for _, client in ipairs(vim.lsp.get_clients({ id = id, method = method })) do
        --
        buffers = vim.tbl_extend("force", buffers, vim.lsp.get_buffers_by_client_id(client.id))
    end

    return buffers
end

---@param callback fun(buf: integer)
---@param id integer?
---@param method string?
M.apply_to_buffers = function(callback, id, method)
    --
    for _, buffer in ipairs(M.buffers_for_client(id, method)) do
        callback(buffer)
    end
end

return M
