return {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml", "toml.pyproject" },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        --
        -- Disable until the issue below is addressed.
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        client.server_capabilities.documentOnTypeFormattingProvider = nil

        keys.map("<leader>vs", function()
            local bufnr = vim.api.nvim_get_current_buf()

            client:request(
                "taplo/associatedSchema",
                vim.tbl_extend("force", vim.lsp.util.make_position_params(0, client.offset_encoding), { documentUri = vim.uri_from_bufnr(bufnr) }),
                function(_, result)
                    vim.ui.float({ ft = "toml", relative = "editor" }, vim.split(result, "\n")):show()
                end,
                bufnr
            )
        end, "Show associated TOML schema")
    end,
    -- This doesn't work. https://github.com/tamasfe/taplo/issues/560
    settings = {
        taplo = {
            config_file = {
                enabled = true,
                path = vim.env.XDG_CONFIG_HOME .. "/taplo.toml",
            },
            schema = {
                enabled = true,
                catalogs = { "https://www.schemastore.org/api/json/catalog.json" },
                cache = {
                    diskExpiration = 600,
                    memoryExpiration = 60,
                },
            },
        },
    },
    single_file_support = true,
}
