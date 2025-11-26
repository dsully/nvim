---@type LazySpec[]
return {
    {
        "diogo464/kubernetes.nvim",
        ft = { "yaml" },
        opts = {
            patch = false,
            schema_generate_always = false,
            schema_strict = true,
        },
    },
    {
        "qvalentin/helm-ls.nvim",
        ft = "helm",
    },
}
