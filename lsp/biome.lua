local function get_biome_config_path()
    local conf = "biome.json"
    local path = vim.fs.joinpath(tostring(vim.uv.cwd()), conf)

    if vim.uv.fs_stat(path) then
        return path
    end

    return vim.fs.joinpath(vim.env.XDG_CONFIG_HOME, conf)
end

---@type vim.lsp.Config
return {
    cmd = { "biome", "lsp-proxy", "--config-path=" .. get_biome_config_path() },
    filetypes = {
        "astro",
        "caddyfile",
        "css",
        "graphql",
        "javascript",
        "javascriptreact",
        "json",
        "json5",
        "jsonc",
        "svelte",
        "typescript",
        "typescript.tsx",
        "typescriptreact",
        "vue",
    },
    root_markers = { "biome.json", "biome.jsonc" },
    single_file_support = true,
}
