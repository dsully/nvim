---@type vim.lsp.Config
return {
    cmd = { "harper-ls", "--stdio" },
    filetypes = { "gitcommit", "markdown" },
    settings = {
        ["harper-ls"] = {
            codeActions = {
                ForceStable = true,
            },
            linters = {
                -- Dashes = false,
                -- LongSentences = false,
                -- Matcher = false, -- e.g. deps to dependencies
                -- Spaces = false,
                SpellCheck = false,
                -- ToDoHyphen = false,
            },
            markdown = {
                IgnoreLinkTitle = true,
            },
            userDictPath = nvim.file.xdg_config("/harper/dict.txt"),
        },
    },
    single_file_support = true,
}
