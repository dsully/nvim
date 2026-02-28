---@type vim.lsp.Config
return {
    cmd = {
        "ty",
        "server",
    },
    filetypes = { "python" },
    handlers = {
        ["window/showMessage"] = function(_, result)
            if result and result.type == vim.lsp.protocol.MessageType.Error then
                return -- silence error notifications from ty
            end
        end,
    },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        if client.server_capabilities then
        end
    end,
    -- Silence ty server panics (e.g. https://github.com/astral-sh/ty/issues/2401)
    on_error = function(_, _) end,
    root_markers = {
        "Pipfile",
        "pyproject.toml",
        "pyrightconfig.json",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
    },
    settings = {
        ty = {
            diagnosticMode = "workspace",
        },
    },
    single_file_support = true,
}
