return {
    cmd = {
        vim.env.HOME .. "/src/rust/ruff/target/release/red_knot",
        "--target-version",
        "3.10",
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
    root_markers = {
        "Pipfile",
        "pyproject.toml",
        "pyrightconfig.json",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
    },
    single_file_support = true,
    trace = "messages",
}
