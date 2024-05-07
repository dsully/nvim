local M = {}

local e = require("helpers.event")

local name = "lightbulb"
local namespace = ns(name)
local group = e.group(name)
local code_action_method = vim.lsp.protocol.Methods.textDocument_codeAction

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
            diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr, line),
            only = { "quickfix" },
            triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Automatic,
        },
    })

    vim.lsp.buf_request(bufnr, code_action_method, params, function(_err, responses, _ctx, _config)
        if vim.api.nvim_get_current_buf() ~= bufnr then
            return
        end

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
    end)
end

---@param bufnr number
local function update(bufnr)
    timer:stop()

    update_extmark(updated_bufnr)

    timer:start(100, 0, function()
        timer:stop()

        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_get_current_buf() == bufnr then
                render(bufnr)
            end
        end)
    end)
end

M.setup = function()
    e.on(e.LspAttach, function(args)
        -- Skip ignored file types and buffer types.
        if
            vim.tbl_contains(require("config.defaults").ignored.file_types, vim.bo.filetype)
            or vim.tbl_contains(require("config.defaults").ignored.buffer_types, vim.bo.buftype)
        then
            return
        end

        local client = vim.lsp.get_client_by_id(args.data.client_id)

        if not client or not client.supports_method(code_action_method) then
            return
        end

        for _, ignored in ipairs(require("config.defaults").ignored.lsp) do
            if client.name == ignored then
                return
            end
        end

        local buf = args.buf
        local buf_group_name = name .. tostring(buf)

        if pcall(vim.api.nvim_get_autocmds, { group = buf_group_name, buffer = buf }) then
            return
        end

        local lb_buf_group = e.group(buf_group_name)

        e.on(e.CursorMoved, function()
            update(buf)
        end, {
            buffer = buf,
            desc = "Update lightbulb when moving the cursor in normal/visual mode",
            group = lb_buf_group,
        })

        e.on({ e.InsertEnter, e.BufLeave }, function()
            update_extmark(buf, nil)
        end, {
            buffer = buf,
            desc = "Update lightbulb when entering insert mode or leaving the buffer",
            group = lb_buf_group,
        })
    end, {
        desc = "Configure code action lightbulb",
        group = group,
    })

    e.on(e.LspDetach, function(args)
        pcall(vim.api.nvim_del_augroup_by_name, name .. tostring(args.buf))
    end, {
        desc = "Detach code action lightbulb",
        group = group,
    })
end

return M
