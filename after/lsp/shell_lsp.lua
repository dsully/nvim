---@type vim.lsp.Config
return {
    cmd = { "shell-lsp" },
    filetypes = {
        "bash",
        "direnv",
        "ksh",
        "sh",
        "zsh",
    },
    settings = {
        shellLsp = {
            format = {
                indent = 4,
                binaryNextLine = true,
                simplify = true,
                spaceRedirects = true,
                switchCaseIndent = true,
            },
        },
    },
}
