---@type vim.lsp.Config
return {
    cmd = { "gh-actions-language-server", "--stdio" },
    filetypes = { "yaml.github" },
    handlers = {
        ["textDocument/publishDiagnostics"] = function(err, result, ctx)
            --
            result.diagnostics = vim.tbl_filter(function(diagnostic)
                -- silence annoying context warnings https://github.com/github/vscode-github-actions/issues/222
                if diagnostic.message:match("Context access might be invalid:") then
                    return false
                end

                -- https://github.com/github/vscode-github-actions/issues/433
                if diagnostic.message:match("Unable to resolve action") then
                    return false
                end

                return true
            end, result.diagnostics)

            vim.lsp.handlers[ctx.method](err, result, ctx)
        end,
    },
    init_options = {
        sessionToken = vim.env.GITHUB_API_TOKEN,
    },
    root_markers = { ".github" },
    single_file_support = true,
}
