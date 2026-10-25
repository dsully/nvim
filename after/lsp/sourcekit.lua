---@type vim.lsp.Config
return {
    cmd = {
        "xcrun",
        "sourcekit-lsp",
        "--default-workspace-type",
        "buildServer",
    },
    cmd_env = (function()
        local dev = "/Applications/Xcode.app/Contents/Developer"
        return {
            DEVELOPER_DIR = dev,
            SDKROOT = vim.fn.system({ "env", "DEVELOPER_DIR=" .. dev, "xcrun", "--show-sdk-path" }):gsub("%s+$", ""),
        }
    end)(),
    filetypes = {
        "swift",
        "c",
        "cpp",
        "objc",
        "objcpp",
    },
    ---@param client vim.lsp.Client
    on_attach = function(client, _bufnr)
        if client.server_capabilities then
            client.server_capabilities.semanticTokensProvider = nil
        end
    end,
    root_markers = {
        ".git",
        "buildServer.json",
        "Package.swift",
    },
}
