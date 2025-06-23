return {
    cmd = { "pyrefly", "lsp" },
    filetypes = { "python" },
    root_markers = {
        "pyrefly.toml",
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
    },
    on_exit = function(code, _, _)
        vim.notify("Closing Pyrefly LSP exited with code: " .. code, vim.log.levels.INFO)
    end,
}
