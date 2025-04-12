---@type vim.lsp.Config
return {
    cmd = { "harper-ls", "--stdio" },
    filetypes = { "gitcommit", "markdown", "text" },
    settings = {
        ["harper-ls"] = {
            codeActions = {
                forceStable = true,
            },
            -- typos handles spell checking
            linters = {
                sentence_capitalization = false,
                spell_check = false,
            },
            userDictPath = nvim.file.xdg_config("/harper/dict.txt"),
        },
    },
    single_file_support = true,
}
