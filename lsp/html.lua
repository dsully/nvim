---@type vim.lsp.Config
return {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html" },
    init_options = {
        provideFormatter = true,
        embeddedLanguages = { css = true, javascript = true },
        configurationSection = { "html", "css", "javascript" },
    },
    single_file_support = true,
}
