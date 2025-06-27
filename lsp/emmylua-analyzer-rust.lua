---@type vim.lsp.Config
local config = {
    cmd = {
        "emmylua_ls",
    },
    filetypes = { "lua" },
    root_markers = {
        ".emmyrc.json",
        ".luarc.json",
        ".luarc.jsonc",
        ".stylua.toml",
        "lazy-lock.json",
        "selene.toml",
        "selene.yml",
        "stylua.toml",
        "lua/",
    },
    single_file_support = true,
}

local root = require("helpers.file").git_root(true)

if root then
    for _, path in ipairs({ ".emmyrc.json", ".luarc.json" }) do
        if vim.uv.fs_stat(vim.fs.joinpath(root, path)) then
            return config
        end
    end
end

return vim.tbl_extend("keep", config, {
    settings = {
        Lua = {
            diagnostics = {
                globals = {
                    "bit",
                    "package",
                    "require",
                    "vim",
                },
            },
            runtime = {
                version = "LuaJIT",
            },
            workspace = {
                library = {
                    "$VIMRUNTIME",
                },
            },
        },
    },
})
