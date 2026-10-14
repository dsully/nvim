-- Progress messages for Code Companion requests.
local M = {}

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
---@param title string
---@param status "running"|"success"|"failed"
function M.progress(request, title, status)
    vim.api.nvim_echo({ { M.client(request.data.adapter) } }, false, {
        id = "codecompanion." .. tostring(request.data.id),
        kind = "progress",
        source = "codecompanion",
        status = status,
        title = title,
    })
end

function M.setup()
    ---@param request vim.api.keyset.create_autocmd.callback_args
    ev.on(ev.User, function(request)
        M.progress(request, "Code Companion", "running")
    end, {
        pattern = "CodeCompanionRequestStarted",
    })

    ---@param request vim.api.keyset.create_autocmd.callback_args
    ev.on(ev.User, function(request)
        local status = request.data.status
        M.progress(request, M.state[status] or "Cancelled", status == "success" and "success" or "failed")
    end, {
        pattern = "CodeCompanionRequestFinished",
    })
end

return M
