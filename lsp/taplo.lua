---@type vim.lsp.Config
return {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml", "toml.pyproject" },
    init_options = {
        cachePath = nvim.file.xdg_cache("taplo"),
    },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        --
        -- Disable until the issue below is addressed.
        if client.server_capabilities then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            client.server_capabilities.documentOnTypeFormattingProvider = nil
        end

        keys.map("<leader>vs", function()
            local bufnr = vim.api.nvim_get_current_buf()

            client:request(
                "taplo/associatedSchema" --[[@as vim.lsp.protocol.Method.ClientToServer.Request]],
                vim.tbl_extend("force", vim.lsp.util.make_position_params(0, client.offset_encoding), { documentUri = vim.uri_from_bufnr(bufnr) }),
                ---@type lsp.Handler
                function(_err, result, _context, _config)
                    ---@diagnostic disable-next-line: param-type-not-match
                    vim.ui.float({ ft = "toml", relative = "editor" }, vim.split(result, "\n")):show()
                end,
                bufnr
            )
        end, "Show associated TOML schema")
    end,
    -- This doesn't work. https://github.com/tamasfe/taplo/issues/560
    settings = {
        evenBetterToml = {
            semanticTokens = true,
            schema = {
                associations = {
                    ["Cargo.toml"] = "https://json.schemastore.org/cargo.json",
                    ["Makefile.toml"] = "https://json.schemastore.org/cargo-make.json",
                    ["pyproject.toml"] = "https://json.schemastore.org/pyproject.json",
                    ["rust-toolchain.toml"] = "https://json.schemastore.org/rust-toolchain.json",
                    ["starship.toml)"] = "https://starship.rs/config-schema.json",
                    ["**/action.toml"] = "https://json.schemastore.org/github-action.json",
                    ["**/workflow*.toml"] = "https://json.schemastore.org/github-workflow.json",
                },
                cache = {
                    diskExpiration = 60 * 60 * 24,
                    memoryExpiration = 60 * 10,
                },
                links = true,
            },
            formatter = {
                alignEntries = false,
                arrayAutoExpand = true,
                arrayTrailingComma = true,
                compact = false,
                indentString = "  ", -- 2 spaces
                indentTables = true,
                reorderArrays = true,
                reorderInlineTables = true,
                reorderKeys = true,
            },
        },
    },
    single_file_support = true,
}
