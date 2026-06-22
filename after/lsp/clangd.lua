---@param client vim.lsp.Client
---@param buf integer
local function switch_source_header(client, buf)
    client:request("textDocument/switchSourceHeader", vim.lsp.util.make_text_document_params(buf), function(err, result)
        if err then
            vim.notify(err.message, vim.log.levels.ERROR)
            return
        end

        if not result then
            vim.notify("clangd: corresponding file could not be determined", vim.log.levels.WARN)
            return
        end

        vim.cmd.edit(vim.uri_to_fname(result))
    end, buf)
end

---@type vim.lsp.Config
return {
    cmd = {
        "clangd",
        "--background-index",
        "--header-insertion=never",
        "--completion-style=detailed",
        "--pch-storage=memory",
        "--all-scopes-completion",
        "--enable-config",
    },
    capabilities = {
        -- Off-spec, but clangd and vim.lsp support utf-8, which is more
        -- efficient. Negotiated in on_init below; replaces a hardcoded
        -- --offset-encoding cmd flag.
        offsetEncoding = { "utf-8", "utf-16" },
    },
    ---@param client vim.lsp.Client
    on_init = function(client, init_result)
        if init_result.offsetEncoding then
            client.offset_encoding = init_result.offsetEncoding
        end
    end,
    ---@param client vim.lsp.Client
    ---@param buf integer
    on_attach = function(client, buf)
        vim.api.nvim_buf_create_user_command(buf, "ClangdSwitchSourceHeader", function()
            switch_source_header(client, buf)
        end, { desc = "clangd: switch between source and header" })

        keys.bmap("grs", function()
            switch_source_header(client, buf)
        end, "Switch Source/Header", buf)
    end,
}
