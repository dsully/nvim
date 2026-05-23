---@type vim.lsp.Config
return {
    cmd = { "harper-ls", "--stdio" },
    filetypes = { "gitcommit" },
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
    override = function(config)
        Snacks.toggle({
            name = "Harper",
            get = function()
                return vim.lsp.is_enabled("harper_ls")
            end,
            set = function(state)
                vim.lsp.enable("harper_ls", state)
            end,
        }):map("<space>tH")

        return config
    end,
    single_file_support = true,
}
