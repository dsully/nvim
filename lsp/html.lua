return {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html", "htmldjango", "templ" },
    init_options = {
        provideFormatter = true,
        embeddedLanguages = { css = true, javascript = true },
        configurationSection = { "html", "css", "javascript" },
    },
    single_file_support = true,
}
