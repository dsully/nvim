-- Noice "LSP" progress for Code Companion requests.
local M = {}

---@type table<string, NoiceMessage?>
M.messages = {}

M.state = {
    success = "Completed",
    error = "Error",
}

---Find the name of the LLM model being used.
---
---@param adapter CodeCompanion.Adapter
---@return string
function M.client(adapter)
    local parts = { adapter.formatted_name }

    if adapter.model ~= nil then
        parts[#parts + 1] = "(" .. adapter.model .. ")"
    end

    return table.concat(parts, " ")
end

---@param request vim.api.keyset.create_autocmd.callback_args
---@param opts table<string, any>?
function M.progress(request, opts)
    opts = opts or {}

    ---@type string
    local id = request.data.id
    local message = M.messages[id]

    if message == nil then
        ---@cast message NoiceMessage
        message = require("noice.message")("lsp", "progress")

        ---@diagnostic disable-next-line: inject-field
        message.opts.progress = {
            client_id = "client " .. id,
            client = M.client(request.data.adapter),
            id = id,
        }

        M.messages[id] = message
    end

    message.opts.progress = vim.tbl_deep_extend("force", message.opts.progress, opts)

    if message.opts.progress.kind == "end" then
        local manager = require("noice.message.manager")
        local router = require("noice.message.router")

        vim.defer_fn(function()
            M.update()
            router.update()
            manager.remove(message)

            M.messages[id] = nil
        end, 100)
    end

    M.update()
end

---@generic F: fun()
---@return F|Interval
function M.update()
    error("Unreachable!")
end

function M.setup()
    local opts = require("noice.config").options.lsp.progress
    local format = require("noice.text.format").format
    local manager = require("noice.message.manager")

    M.update = require("noice.util").interval(opts.throttle, function()
        --
        for _, message in pairs(M.messages) do
            manager.add(format(message, message.opts.progress.kind == "end" and opts.format_done or opts.format))
        end
    end, {
        enabled = function()
            return not vim.tbl_isempty(M.messages)
        end,
    })

    ---@param request vim.api.keyset.create_autocmd.callback_args
    ev.on(ev.User, function(request)
        M.progress(request, { title = "Code Companion", kind = "start" })
    end, {
        pattern = "CodeCompanionRequestStarted",
    })

    ---@param request vim.api.keyset.create_autocmd.callback_args
    ev.on(ev.User, function(request)
        M.progress(request, {
            title = M.state[request.data.status] or "Cancelled",
            kind = "end",
        })
    end, {
        pattern = "CodeCompanionRequestFinished",
    })
end

return M
