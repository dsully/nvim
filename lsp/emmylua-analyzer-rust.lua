local settings = {}

if vim.fs.find({ ".emmyrc.json", ".luarc.json" }, { path = require("helpers.file").git_root(), type = "file" }) == false then
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
    }
end

---@type vim.lsp.Config
return {
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
    settings = settings,
    single_file_support = true,
}
