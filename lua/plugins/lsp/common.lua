local M = {}

local e = require("helpers.event")
local lsp = require("helpers.lsp")

---@alias LspProgressEvent {data: LspProgressEventData}
---@alias LspProgressEventData {client_id: integer, params: lsp.ProgressParams}

-- Hook up autocomplete for LSP to nvim-cmp, see: https://github.com/hrsh7th/cmp-nvim-lsp
---@return lsp.ClientCapabilities
M.capabilities = function()
    --
    -- Since cmp-nvim-lsp has an after/ file which load cmp, which I want deferred until InsertEnter,
    -- create a cache of the table that .default_capabilities() emits to JSON to be loaded instead.
    local path = vim.fn.stdpath("cache") .. "/capabilities.json"
    local module = "cmp_nvim_lsp"

    if not vim.uv.fs_stat(path) then
        require("lazy").load({ plugins = { "cmp-nvim-lsp" } })

        vim.fn.writefile({ vim.json.encode(require(module).default_capabilities()) }, path)

        require("plenary.reload").reload_module(module)
    end

    return vim.json.decode(vim.fn.readfile(path)[1])
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
    e.on(e.LspAttach, function(args)
        local buffer = args.buf ---@type number
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        if client then
            M.on_attach(client, buffer)
        end
    end, {
        desc = "LSP Common Attach",
    })

    ---@param event LspProgressEvent
    e.on(e.LspProgress, function(event)
        --
        if event.data.client_id and event.data.params then
            require("helpers.code_lens").on_progress(event.data)
        end
    end, { desc = "LSP Progress Handler" })

    require("helpers.handlers").setup()
    require("helpers.lightbulb").setup()

    return M.capabilities()
end

---@param client vim.lsp.Client
---@param buffer integer
M.on_attach = function(client, buffer)
    local keys = require("helpers.keys")
    local methods = vim.lsp.protocol.Methods

    if lsp.should_ignore(client) then
        return
    end

    if client.supports_method(methods.textDocument_documentHighlight) then
        --
        local method = vim.lsp.protocol.Methods.textDocument_documentHighlight

        e.on({ e.BufEnter, e.CursorHold, e.CursorHoldI }, function(args)
            --
            local buf_group = e.group(("document_highlight/buffer/%s"):format(args.buf), false)

            if #vim.lsp.get_clients({ id = client.id, bufnr = args.buf, method = method }) > 0 then
                vim.lsp.buf.clear_references()
                vim.lsp.buf.document_highlight()
            end

            e.on({ e.BufLeave, e.CursorMoved, e.CursorMovedI }, vim.lsp.buf.clear_references, {
                buffer = args.buf,
                desc = "LSP Clear References",
                group = buf_group,
            })

            -- Remove the group when there are no more buffers associated with the client.
            e.on({ e.BufDelete }, function()
                vim.api.nvim_del_augroup_by_id(buf_group)
            end, {
                buffer = args.buf,
                desc = "LSP Code Lens Clean Up",
                group = buf_group,
            })
        end, {
            desc = "LSP Document Highlighting",
        })
    end

    if client.supports_method(methods.textDocument_inlayHint) then
        keys.bmap("<space>i", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buffer }))
        end, " Toggle Inlay Hints")

        vim.lsp.inlay_hint.enable(false)
    end
end

-- Adapted from folke/lazyvim
-- Searches & sets the root directory based on:
--
-- * LSP workspace folders
-- * LSP root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
M.find_root = function()
    local defaults = require("config.defaults")

    local bufnr = vim.api.nvim_get_current_buf()

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
        root = root and vim.fs.dirname(root) or cwd
    end

    ---@cast root string
    return root
end

return M
