local function get_biome_config_path()
    local conf = "biome.json"
    local path = vim.fs.joinpath(tostring(vim.uv.cwd()), conf)

    if vim.uv.fs_stat(path) then
        return path
    end

    return nvim.file.xdg_config(conf)
end

---@type vim.lsp.Config
return {
    cmd = { "biome", "lsp-proxy", "--config-path=" .. get_biome_config_path() },
    filetypes = {
        "astro",
        "caddy",
        "css",
        "graphql",
        "javascript",
        "javascriptreact",
        "svelte",
        "typescript",
        "typescript.tsx",
        "typescriptreact",
        "vue",
    },
    root_markers = { "biome.json", "biome.jsonc" },
    single_file_support = true,
}
