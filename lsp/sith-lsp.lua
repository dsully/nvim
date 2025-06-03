---@type vim.lsp.Config
return {
    cmd = { "sith-lsp" },
    filetypes = {
        "python",
    },
    init_options = {
        settings = {
            ruff = {
                path = vim.fn.executable("ruff"),
            },
        },
    },
    root_dir = function(_bufnr, _on_dir)
        if vim.env.SITH ~= nil then
            on_dir(vim.uv.cwd())
        end
    end,
    root_markers = {
        "pyproject.toml",
        "requirements.txt",
        "setup.cfg",
        "setup.py",
    },
    single_file_support = true,
}
