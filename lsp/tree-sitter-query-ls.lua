-- Disable the (slow) builtin query linter
vim.g.query_lint_on = {}

---@type vim.lsp.Config
return {
    cmd = { "ts_query_ls" },
    filetypes = { "query" },
    root_dir = vim.fs.root(0, { "queries" }),
    settings = {
        parser_aliases = {
            ecma = "javascript",
        },
        parser_install_directories = {
            vim.fs.joinpath(vim.g.ts_path, "parser/"),
        },
    },
    single_file_support = true,
}
