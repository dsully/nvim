---@type vim.lsp.Config
return {
    cmd = { "sourcekit-lsp" },
    filetypes = { "swift" },
    capabilities = {
        workspace = {
            didChangeWatchedFiles = {
                dynamicRegistration = true,
            },
        },
    },
}
