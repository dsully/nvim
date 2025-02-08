---@type vim.lsp.Config
return {
    cmd = { "bash-language-server", "start" },
    filetypes = { "bash", "direnv", "sh", "zsh" },
    --
    ---@param client vim.lsp.Client
    on_attach = function(client)
        if client.server_capabilities then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end
    end,
    settings = {
        bashIde = {
            globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
            includeAllWorkspaceSymbols = true,
        },
    },
    single_file_support = true,
}
