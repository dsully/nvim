local M = {}

local e = require("helpers.event")

local name = "lightbulb"
local namespace = ns(name)
local methods = vim.lsp.protocol.Methods

local timer = vim.uv.new_timer()
assert(timer, "Timer was not initialized")

local updated_bufnr = nil

--- Updates the current light bulb.
---@param bufnr number?
---@param line number?
local function update_extmark(bufnr, line)
    --
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

    -- Extra check for not being in insert mode here because sometimes the autocommand fails with motions.
    if not line or vim.startswith(vim.api.nvim_get_mode().mode, "i") then
        return
    end

    pcall(vim.api.nvim_buf_set_extmark, bufnr, namespace, line, -1, {
        sign_text = require("config.defaults").icons.misc.lightbulb,
        sign_hl_group = "DiagnosticSignHint",
        hl_mode = "combine",
    })

    updated_bufnr = bufnr
end

--- Query language servers for code actions and update the light bulb accordingly.
---@param bufnr number
local function render(bufnr)
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1

    local params = vim.tbl_extend("force", vim.lsp.util.make_range_params(), {
        context = {
            diagnostics = vim.diagnostic.get(bufnr, { lnum = line }),
            only = { "quickfix" },
            triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Automatic,
        },
    })

    vim.lsp.buf_request(bufnr, methods.textDocument_codeAction, params, function(_err, responses, _ctx, _config)
        -- Check for available code actions from all LSP server responses
        local has_actions = false

        for _, response in pairs(responses or {}) do
            if response.result and not vim.tbl_isempty(response.result) then
                --
                -- Check all the results to make sure the code action returned has a kind.
                for _, r in pairs(response.result) do
                    if r.kind and r.kind ~= "" then
                        has_actions = true
                        break
                    end
                end
            end
        end

        if has_actions then
            update_extmark(bufnr, (responses and #responses > 0 and line) or nil)
        end
    end, function() end)
end

---@param client vim.lsp.Client
---@param bufnr number
local function update(client, bufnr)
    timer:stop()

    if client.supports_method(methods.textDocument_codeAction, { bufnr = bufnr }) then
        update_extmark(updated_bufnr)

        timer:start(100, 0, function()
            timer:stop()

            vim.schedule(function()
                if vim.api.nvim_get_current_buf() == bufnr then
                    render(bufnr)
                end
            end)
        end)
    end
end

---@param client vim.lsp.Client
---@param buffer integer
---@param group integer
M.setup = function(client, buffer, group)
    --
    e.on(e.CursorMoved, function()
        update(client, buffer)
    end, {
        buffer = buffer,
        desc = "Update lightbulb when moving the cursor in normal/visual mode",
        group = group,
    })

    e.on({ e.InsertEnter, e.BufLeave }, function()
        update_extmark(buffer, nil)
    end, {
        buffer = buffer,
        desc = "Update lightbulb when entering insert mode or leaving the buffer",
        group = group,
    })
end

return M
