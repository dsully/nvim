local M = {}

---@param title string
---@param opts table
local function location_handler(title, opts)
    --
    --- Jumps to a location. Used as a handler for multiple LSP methods.
    ---@param result table result of LSP method; a location or a list of locations.
    ---@param ctx lsp.HandlerContext table containing the context of the request, including the method
    return function(_, result, ctx)
        --
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        local results = {}

        if vim.islist(result) then
            results = result
        else
            results = { result }
        end

        if not result or not results or vim.tbl_isempty(results) or not client then
            vim.api.nvim_echo({ { "LSP: No locations found." } }, false, {})
            return
        end

        if vim.islist(results) then
            local conf = require("telescope.config").values

            local items = vim.lsp.util.locations_to_items(results, client.offset_encoding)
            local lnum, filename = items[1].lnum, items[1].filename
            local picked = false

            for _, val in pairs(items) do
                if val.lnum ~= lnum or val.filename ~= filename then
                    picked = true
                end
            end

            if picked then
                require("telescope.pickers")
                    .new(opts, {
                        prompt_title = title,
                        finder = require("telescope.finders").new_table({
                            results = items,
                            entry_maker = opts.entry_maker or require("telescope.make_entry").gen_from_quickfix(),
                        }),
                        previewer = conf.qflist_previewer(opts),
                        sorter = conf.generic_sorter(opts),
                        push_cursor_on_edit = true,
                        push_tagstack_on_edit = true,
                    })
                    :find()
            else
                vim.lsp.util.jump_to_location(results[1], client.offset_encoding, false)
            end
        else
            vim.lsp.util.jump_to_location(results[1], client.offset_encoding, true)
        end
    end
end

M.setup = function()
    local opts = {}

    for req, handler in pairs({
        ["textDocument/declaration"] = location_handler("LSP Declarations", opts),
        ["textDocument/definition"] = location_handler("LSP: Definitions", {
            fname_width = 40,
            include_current_line = false,
            trim_text = true,
        }),
        ["textDocument/implementation"] = location_handler("LSP: Implementations", opts),
        ["textDocument/typeDefinition"] = location_handler("LSP Type Definitions", opts),
        ["textDocument/references"] = location_handler("LSP: References", {
            include_current_line = false,
        }),
    }) do
        vim.lsp.handlers[req] = handler
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

    -- Handle dynamic registration.
    --
    -- https://github.com/neovim/neovim/issues/24229
    local register_capability = vim.lsp.handlers["client/registerCapability"]

    --
    ---@param res lsp.RegistrationParams
    ---@param ctx lsp.HandlerContext
    vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
        local client_id = ctx.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        local buffer = vim.api.nvim_get_current_buf()

        if client then
            require("plugins.lsp.common").on_attach(client, buffer)
        end

        return register_capability(err, res, ctx)
    end
end

return M
