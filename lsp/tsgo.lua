---@type vim.lsp.Config
return {
    cmd = { "tsgo", "--lsp", "--stdio" },
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
    },
    single_file_support = true,
}
