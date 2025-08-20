---@type vim.lsp.Config
return {
    -- https://github.com/Myzel394/config-lsp
    cmd = {
        "config-lsp",
        "--no-undetectable-errors",
        "--usage-reports-disable",
    },
    filetypes = {
        "aliases",
        -- Matches wireguard configs and /etc/hosts
        "conf",
        "fstab",
        "sshconfig",
        "sshdconfig",
    },
    single_file_support = true,
}
