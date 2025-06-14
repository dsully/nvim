---@type vim.lsp.Config
return {
    cmd = { "pkl-lsp" },
    filetypes = { "pkl" },
    init_options = {
        extendedClientCapabilities = {
            actionableRuntimeNotifications = true,
        },
    },
    root_markers = {
        ".pkl-lsp",
        "PklProject",
    },
    single_file_support = true,
}
