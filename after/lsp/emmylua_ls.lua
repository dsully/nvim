---@type vim.lsp.Config
return {
    cmd = {
        "emmylua_ls",
    },
    filetypes = { "lua" },
    on_init = function(client)
        -- If the workspace has its own emmylua_ls/lua_ls config file, defer to it.
        if client.workspace_folders then
            local path = client.workspace_folders[1].name

            if path ~= vim.fn.stdpath("config") and (vim.uv.fs_stat(path .. "/.emmyrc.json") or vim.uv.fs_stat(path .. "/.luarc.json")) then
                client.config.settings = {}
            end
        end
    end,
    root_dir = function(bufnr, on_dir)
        local nvim_config = nvim.file.realpath(nvim.file.xdg_config("nvim"))
        local bufname = nvim.file.filename(bufnr)

        if bufname == nvim_config or vim.startswith(bufname, nvim_config .. "/") then
            on_dir(nvim_config)
        end
    end,
    ---@type lspconfig.settings.emmylua_ls
    settings = {
        emmylua = {
            diagnostics = {
                globals = { "vim" },
            },
            -- Tell the server which Lua you're using (usually LuaJIT, for Neovim).
            runtime = {
                version = "LuaJIT",
            },
            -- Make the server aware of Neovim runtime files.
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                    vim.env.XDG_DATA_HOME .. "/nvim/lazy",
                    -- vim.env.XDG_DATA_HOME .. "/nvim/site/pack/core/opt",
                    -- LSP Settings Type Annotations
                    -- https://github.com/neovim/nvim-lspconfig#lsp-settings-type-annotations
                    vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1],
                },
                -- Or pull in all of 'runtimepath'. May be slower!
                -- library = vim.api.nvim_get_runtime_file('', true),
            },
        },
    },
    single_file_support = false,
    workspace_required = true,
}
