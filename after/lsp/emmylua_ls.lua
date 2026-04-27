---@type vim.lsp.Config
return {
    cmd = {
        "emmylua_ls",
    },
    filetypes = { "lua" },
    root_dir = function(bufnr, on_dir)
        local nvim_config = nvim.file.realpath(nvim.file.xdg_config("nvim"))
        local bufname = nvim.file.filename(bufnr)

        if bufname == nvim_config or vim.startswith(bufname, nvim_config .. "/") then
            on_dir(nvim_config)
        end
    end,
    single_file_support = false,
    workspace_required = true,
}
