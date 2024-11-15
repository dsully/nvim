local root_dir = function()
    return vim.fs.root(0, {
        "Pipfile",
        "pyproject.toml",
        "pyrightconfig.json",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        ".git",
    })
end

return {
    default_config = {
        cmd = {
            vim.env.HOME .. "/src/rust/ruff/target/release/red_knot",
            "--target-version",
            "py310",
            "--venv-path",
            vim.uv.cwd() .. "/.venv",
            "--watch",
            "server",
        },
        filetypes = { "python" },
        init_options = {
            settings = {
                logLevel = "warn",
                logFile = vim.fn.stdpath("log") .. "/lsp.red_knot.log",
            },
        },
        root_dir = root_dir,
        single_file_support = true,
        trace = "messages",
    },
}
