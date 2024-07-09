local M = {}
local e = require("helpers.event")
local lsp = require("helpers.lsp")

---@alias LspProgressInfo {token: integer, buffer: integer}

---@type table<integer, LspProgressInfo>
local clients = {}

local events = { e.BufEnter, e.BufReadPost, e.InsertLeave }
local methods = vim.lsp.protocol.Methods

local code_lens_refresh = function()
    lsp.apply_to_buffers(function(bufnr)
        vim.lsp.codelens.refresh({ bufnr = bufnr })
    end, { method = methods.textDocument_codeLens })
end

---@param data LspProgressEventData
---@param group integer
M.on_progress = function(data, group)
    local id = ("%s.%s"):format(data.client_id, data.params.token)
    local value = data.params.value

    if not clients[id] then
        clients[id] = true
    end

    -- Refresh the code lens when the progress is done and
    -- there are no more buffers in progress for the client.
    if value and value.kind and value.kind == "end" then
        clients[id] = nil

        if vim.tbl_isempty(clients) then
            vim.defer_fn(code_lens_refresh, 100)

            e.on(events, code_lens_refresh, {
                desc = "LSP Code Lens Refresh",
                group = group,
            })
        end
    end

    require("helpers.keys").bmap("clr", vim.lsp.codelens.refresh, "Refresh CodeLens")
end

return M
