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

    -- Jump directly to the first available definition every time.
    -- Use Telescope if there is more than one result.
    vim.lsp.handlers["textDocument/definition"] = function(_, result, ctx)
        if not result or vim.tbl_isempty(result) then
            vim.api.nvim_echo({ { "LSP: Could not find definition" } }, false, {})
            return
        end

        local client = vim.lsp.get_client_by_id(ctx.client_id)

        if not client then
            return
        end

        if vim.tbl_islist(result) then
            local results = vim.lsp.util.locations_to_items(result, client.offset_encoding)
            local lnum, filename = results[1].lnum, results[1].filename

            for _, val in pairs(results) do
                if val.lnum ~= lnum or val.filename ~= filename then
                    return require("telescope.builtin").lsp_definitions()
                end
            end

            vim.lsp.util.jump_to_location(result[1], client.offset_encoding, false)
        else
            vim.lsp.util.jump_to_location(result, client.offset_encoding, true)
        end
    end

    -- De-duplicate diagnostics, in particular from rust-analyzer/rustc
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(function(_, result, ...)
        --
        ---@type table<string, boolean>>
        local seen = {}

        ---@param diagnostic lsp.Diagnostic
        result.diagnostics = vim.iter.filter(function(diagnostic)
            local key = string.format("%s:%s", diagnostic.code, diagnostic.range.start.line)

            if not seen[key] then
                seen[key] = true
                return true
            end

            return false
        end, result.diagnostics)

        vim.lsp.diagnostic.on_publish_diagnostics(_, result, ...)
    end, {})

    return M.capabilities()
end

---@param client lsp.Client
---@param buffer integer
M.on_attach = function(client, buffer)
    local methods = vim.lsp.protocol.Methods
    local keys = require("helpers.keys")

    local bmap = function(lhs, rhs, opts)
        keys.bmap(buffer, "n", lhs, rhs, opts)
    end

    --
    -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#highlight-symbol-under-cursor

    if client.supports_method(methods.textDocument_documentHighlight) then
        local group = vim.api.nvim_create_augroup("LSP Highlight References", { clear = false })

        e.on({ e.BufEnter, e.CursorHold, e.InsertLeave }, vim.lsp.buf.document_highlight, {
            buffer = buffer,
            desc = ("LSP Document Highlight for: %s/%s"):format(client.name, buffer),
            group = group,
        })

        e.on({ e.BufLeave, e.CursorMoved, e.InsertEnter }, vim.lsp.buf.clear_references, {
            buffer = buffer,
            desc = ("LSP Clear References for: %s/%s"):format(client.name, buffer),
            group = group,
        })
    end

    -- General diagnostics.
    bmap("]d", vim.diagnostic.goto_next, { desc = "󰙨󰙨 Next Diagnostic" })
    bmap("[d", vim.diagnostic.goto_prev, { desc = "󰙨󰙨 Previous Diagnostic" })
    bmap("<leader>xr", vim.diagnostic.reset, { desc = " Reset" })
    bmap("<leader>xs", vim.diagnostic.open_float, { desc = "󰙨 Show" })

    if client.supports_method(methods.textDocument_signatureHelp) then
        bmap("<leader>ch", vim.lsp.buf.signature_help, { desc = "󰞂 Signature Help" })
    end

    if client.supports_method(methods.textDocument_declaration) then
        bmap("gD", vim.lsp.buf.declaration, { desc = "󰁴 Go To Declaration" })
    end

    if client.supports_method(methods.textDocument_inlayHint) then
        bmap("<space>i", vim.lsp.inlay_hint.enable, { desc = " Toggle Inlay Hints" })

        vim.lsp.inlay_hint.enable(buffer, false)
    end

    if client.supports_method(methods.textDocument_hover) then
        bmap("K", vim.lsp.buf.hover, { desc = "Documentation  " })
    end

    if client.supports_method(methods.textDocument_codeAction) then
        vim.keymap.set({ "n", "x" }, "<leader>ca", function()
            require("actions-preview").code_actions({ context = { only = { "quickfix" } } })
        end, { buffer = buffer, desc = "󰅯 Actions" })
    end

    -- https://github.com/smjonas/inc-rename.nvim
    if client.supports_method(methods.textDocument_rename) then
        bmap("<leader>cr", function()
            --
            return ":" .. require("inc_rename").config.cmd_name .. " " .. vim.fn.expand("<cword>")
        end, { desc = "  Rename", expr = true })
    end

    if client.supports_method(methods.textDocument_codeLens) then
        --
        local desc = ("LSP Code Lens Refresh for: %s/%s"):format(client.name, buffer)
        local group = vim.api.nvim_create_augroup("LSP Code Lens", { clear = false })

        e.on({ e.BufEnter }, vim.lsp.codelens.refresh, {
            buffer = buffer,
            desc = desc,
            group = group,
            once = true,
        })

        e.on({ e.BufWritePost, e.FocusGained, e.InsertLeave }, vim.lsp.codelens.refresh, {
            buffer = buffer,
            desc = desc,
            group = group,
        })
    end

    -- Telescope based finders.
    if client.supports_method(methods.textDocument_definition) then
        bmap("gd", vim.lsp.buf.definition, { desc = "󰁴 Go To Definition(s)" })
    end

    if client.supports_method(methods.textDocument_implementation) then
        bmap("gi", function()
            vim.cmd.Telescope("lsp_implementations")
        end, { desc = "󰘲 Go To Implementations(s)" })
    end

    if client.supports_method(methods.textDocument_references) then
        bmap("<leader>fR", function()
            vim.cmd.Telescope("lsp_references")
        end, { desc = "󰆋 References" })
    end

    if client.supports_method(methods.textDocument_documentSymbol) then
        bmap("<leader>fS", function()
            vim.cmd.Telescope("lsp_document_symbols")
        end, { desc = "󰆋 Symbols" })
    end

    if client.supports_method(methods.workspace_symbol) then
        bmap("<leader>fW", function()
            vim.cmd.Telescope("lsp_dynamic_workspace_symbols")
        end, { desc = "󰆋 Workspace Symbols" })
    end

    -- Diagnostics
    bmap("<leader>xl", function()
        vim.cmd.Telescope("loclist")
    end, { desc = " Location List" })

    bmap("<leader>xq", function()
        vim.cmd.Telescope("quickfix")
    end, { desc = "󰁨 Quickfix" })
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
        path = path and vim.fs.dirname(path) or cwd

        ---@type string?
        root = vim.fs.find(defaults.root_patterns, { path = path, upward = true })[1]
        root = root and vim.fs.dirname(root) or cwd
    end

    ---@cast root string
    return root
end

return M
