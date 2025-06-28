---@type vim.lsp.Config
return {
    cmd = { "biome", "lsp-proxy" },
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
