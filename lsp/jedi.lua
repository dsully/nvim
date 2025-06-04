---@type vim.lsp.Config
return {
    cmd = { "jedi-language-server" },
    filetypes = { "python" },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        --
        -- Use treesitter highlighting, as it supports injections.
        if client.server_capabilities then
            client.server_capabilities.semanticTokensProvider = nil
        end
    end,
    root_dir = function(_bufnr, on_dir)
        if vim.env.JEDI ~= nil and vim.env.SITH == nil then
            on_dir(vim.uv.cwd())
        end
    end,
    root_markers = {
        "Pipfile",
        "pyproject.toml",
        "requirements.txt",
        "setup.cfg",
        "setup.py",
    },
    settings = {
        completion = {
            disableSnippets = true,
        },
    },
    single_file_support = true,
}
