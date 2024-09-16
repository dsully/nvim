local M = {}

local methods = vim.lsp.protocol.Methods

---@class LspClientBuffers
---@field client vim.lsp.Client
---@field buffers integer[]

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
    --
    ---@type LspClientBuffers[]
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

-- Hook up autocomplete for LSP to nvim-cmp, see: https://github.com/hrsh7th/cmp-nvim-lsp
---@return lsp.ClientCapabilities
M.capabilities = function()
    return vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), require("cmp_nvim_lsp").default_capabilities() or {})
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

---@return lsp.ClientCapabilities
M.setup = function()
    -- Handle dynamic registration.
    --
    -- https://github.com/neovim/neovim/issues/24229
    local register_capability = vim.lsp.handlers[methods.client_registerCapability]

    ---@param res lsp.RegistrationParams
    ---@param ctx lsp.HandlerContext
    vim.lsp.handlers[methods.client_registerCapability] = function(err, res, ctx)
        local client_id = ctx.client_id
        local client = vim.lsp.get_client_by_id(client_id)

        if client then
            for buffer in pairs(client.attached_buffers) do
                --
                ev.emit(ev.User, {
                    pattern = ev.LspDynamicCapability,
                    data = { client_id = client.id, buffer = buffer },
                })
            end
        end

        return register_capability(err, res, ctx)
    end

    M.on_attach(M.validate_client)
    M.on_dynamic_capability(M.validate_client)

    return M.capabilities()
end

---@type table<string, table<vim.lsp.Client, table<number, boolean>>>
M.supports_method = {}

---@param client vim.lsp.Client
function M.validate_client(client, buffer)
    if buffer == nil or not vim.api.nvim_buf_is_valid(buffer) then
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
            if client.supports_method and client.supports_method(method, { bufnr = buffer }) then
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
        local buffer = args.buf ---@type number
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

-- Adapted from https://gist.github.com/MunifTanjim/8d9498c096719bdf4234321230fe3dc7
M.rename = function()
    local Input = require("nui.input")
    local event = require("nui.utils.autocmd").event

    local current_name = vim.fn.expand("<cword>")

    local params = vim.lsp.util.make_position_params()

    local function on_submit(new_name)
        --
        if not new_name or #new_name == 0 then
            vim.api.nvim_notify("Cancelled: New name is empty!", vim.log.levels.INFO, {
                icon = "",
                title = "LSP",
            })
            return
        elseif new_name == current_name then
            vim.api.nvim_notify("Cancelled: New and current names are the same!", vim.log.levels.INFO, {
                icon = "",
                title = "LSP",
            })
            return
        end

        local relative_path = function(file_path)
            local plenary_path = require("plenary.path")
            local parsed_path, _ = file_path:gsub("file://", "")
            local path = plenary_path:new(parsed_path)
            local relative_path = path:make_relative(vim.uv.cwd())
            return "./" .. relative_path
        end

        params.newName = new_name ---@diagnostic disable-line: inject-field

        vim.lsp.buf_request(0, methods.textDocument_rename, params, function(err, result, ctx, _)
            --
            if err or not result then
                vim.notify(("Error running LSP query '%s': %s"):format(ctx.method, err), vim.log.levels.ERROR)
                return
            end

            -- The `result` contains all the places we need to update the name of the identifier. so we apply those edits.
            vim.lsp.util.apply_workspace_edit(result, vim.lsp.get_client_by_id(ctx.client_id).offset_encoding)

            -- Display notification with the changed files
            -- https://github.com/mattleong/CosmicNvim/blob/85fea07d98a340813898c35ea8266efdd826fe88/lua/cosmic/core/theme/ui.lua
            if result.documentChanges then
                local msg = {}

                for _, changes in pairs(result.documentChanges) do
                    table.insert(msg, ("%d changes: %s"):format(#changes.edits, relative_path(changes.textDocument.uri)))
                end

                vim.api.nvim_notify("Renamed " .. current_name .. " into " .. new_name .. ".", vim.log.levels.INFO, {
                    icon = "",
                    title = "LSP",
                })

                -- After the edits are applied, the files are not saved automatically.
                local total_files = vim.tbl_count(result.documentChanges)

                print(string.format("Changed %s file%s. To save them run ':wa'", total_files, total_files > 1 and "s" or ""))
            end
        end)
    end

    local popup_options = {
        border = {
            style = defaults.ui.border.name,
            text = {
                top = "[Rename]",
                top_align = "left",
            },
        },
        highlight = "Normal:Normal,FloatBorder:DiagnosticInfo",
        -- Place the pop-up window relative to the buffer position of the identifier.
        relative = {
            type = "cursor",
            position = {
                row = params.position.line,
                col = params.position.character,
            },
        },
        -- Position the pop-up window on the line below identifier
        position = {
            row = -2,
            col = -2,
        },
        size = {
            width = math.max(#current_name + 20, 35),
            height = 2,
        },
    }

    local input = Input(popup_options, {
        default_value = current_name,
        on_submit = on_submit,
        prompt = " ",
    })

    input:mount()

    -- Make it easier to move around long words
    local kw = vim.opt.iskeyword - "_" - "-"
    vim.bo.iskeyword = table.concat(kw:get(), ",")

    -- Close on <esc> in normal mode
    input:map("n", "<esc>", input.input_props.on_close, { noremap = true })
    input:map("n", "<C-c>", input.input_props.on_close, { noremap = true })

    -- Ctrl-W to delete word.
    input:map("i", "<C-w>", "<C-o>diw", { noremap = true, silent = true })

    -- Close when cursor leaves the buffer
    input:on(event.BufLeave, input.input_props.on_close, { once = true })
end

-- Adapted from folke/lazyvim
-- Searches & sets the root directory based on:
--
-- * LSP workspace folders
-- * LSP root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
M.find_root = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    ---@type string?
    local path = vim.api.nvim_buf_get_name(bufnr)
    path = path ~= "" and vim.uv.fs_realpath(path) or nil

    ---@type string[]
    local roots = {}
    local cwd = vim.uv.cwd()

    if path then
        for _, client in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            if not vim.tbl_contains(defaults.ignored.lsp, client.name) then
                local workspace = client.config.workspace_folders

                local paths = workspace and vim.tbl_map(function(ws)
                    return vim.uri_to_fname(ws.uri)
                end, workspace) or client.config.root_dir and { client.config.root_dir } or {}

                for _, p in ipairs(paths) do
                    local r = vim.uv.fs_realpath(p)

                    if r then
                        if path:find(r, 1, true) then
                            roots[#roots + 1] = r
                        end
                    end
                end
            end
        end
    end

    table.sort(roots, function(a, b)
        return #a > #b
    end)

    ---@type string?
    local root = roots[1]

    if not root then
        ---@type string?
        root = vim.fs.root(bufnr, defaults.root_patterns)
        root = root and root or cwd
    end

    ---@cast root string
    return root
end

return M
