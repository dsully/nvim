local M = {}

local e = require("helpers.event")

-- Hook up autocomplete for LSP to nvim-cmp, see: https://github.com/hrsh7th/cmp-nvim-lsp
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

M.setup = function()
    e.on(e.LspAttach, function(args)
        local buffer = args.buf ---@type number
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        if client then
            M.on_attach(client, buffer)
        end
    end)

    -- Handle dynamic registration.
    --
    -- https://github.com/neovim/neovim/issues/24229
    local register_capability = vim.lsp.handlers["client/registerCapability"]

    vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
        local client_id = ctx.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        local buffer = vim.api.nvim_get_current_buf()

        if client then
            M.on_attach(client, buffer)
        end

        return register_capability(err, res, ctx)
    end

    -- De-duplicate diagnostics, in particular from rust-analyzer/rustc
    ---@param result lsp.PublishDiagnosticsParams
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(function(_, result, ...)
        --
        ---@type table<string, lsp.Diagnostic>>
        local seen = {}

        ---@param diagnostic lsp.Diagnostic
        for _, diagnostic in ipairs(result.diagnostics) do
            local key = string.format("%s:%s", diagnostic.code, diagnostic.range.start.line)

            seen[key] = diagnostic
        end

        result.diagnostics = vim.tbl_values(seen)

        vim.lsp.diagnostic.on_publish_diagnostics(_, result, ...)
    end, {})

    return M.capabilities()
end

---@param client vim.lsp.Client
---@param buffer integer
M.on_attach = function(client, buffer)
    local methods = vim.lsp.protocol.Methods
    local keys = require("helpers.keys")

    --
    -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#highlight-symbol-under-cursor

    if client.supports_method(methods.textDocument_documentHighlight) then
        e.on({ e.BufEnter, e.CursorHold, e.CursorHoldI }, function(args)
            --
            if #vim.lsp.get_clients({ bufnr = args.buf, method = methods.textDocument_documentHighlight }) > 0 then
                vim.lsp.buf.clear_references()
                vim.lsp.buf.document_highlight()
            end
        end, {
            buffer = buffer,
            desc = ("LSP Document Highlight for: %s/%s"):format(client.name, buffer),
        })

        e.on({ e.BufLeave, e.CursorMoved, e.CursorMovedI }, vim.lsp.buf.clear_references, {
            buffer = buffer,
            desc = ("LSP Clear References for: %s/%s"):format(client.name, buffer),
        })
    end

    if client.supports_method(methods.textDocument_inlayHint) then
        keys.bmap("<space>i", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, " Toggle Inlay Hints")

        vim.lsp.inlay_hint.enable(false)
    end

    if client.supports_method(methods.textDocument_codeLens) then
        --
        e.on({ e.BufReadPost, e.InsertLeave }, function(args)
            --
            if #vim.lsp.get_clients({ bufnr = args.buf, method = methods.textDocument_codeLens }) > 0 then
                vim.lsp.codelens.refresh({ bufnr = args.buf })
            end
        end, {
            buffer = buffer,
            desc = ("LSP Code Lens Refresh for: %s/%s"):format(client.name, buffer),
        })

        keys.bmap("clr", vim.lsp.codelens.refresh, "Refresh CodeLens")
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
