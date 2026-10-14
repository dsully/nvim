---@type vim.lsp.Config
return {
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        if client.server_capabilities then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end
    end,
    root_dir = function(bufnr, on_dir)
        local root_markers = { { "package-lock.json", "yarn.lock", "pnpm-lock.yaml" }, { ".git" } }

        -- Fallback to the current working directory if no project root is found.
        local project_root = vim.fs.root(bufnr, root_markers) or nvim.file.cwd()

        on_dir(project_root)
    end,
}
