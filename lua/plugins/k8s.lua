---@type LazySpec[]
return {
    {
        "ramilito/kubectl.nvim",
        -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
        -- build = 'cargo build --release',
        dependencies = "saghen/blink.download",
        keys = {
            {
                "<leader>k",
                function()
                    require("kubectl").toggle({ tab = false })
                end,
                desc = "Kubectl",
            },
            -- https://github.com/Ramilito/kubectl.nvim/wiki/Lazy-setup
            { "<C-k>", "<Plug>(kubectl.kill)", ft = "k8s_*" },
            { "7", "<Plug>(kubectl.view_nodes)", ft = "k8s_*" },
            { "8", "<Plug>(kubectl.view_overview)", ft = "k8s_*" },
            { "<C-t>", "<Plug>(kubectl.view_top)", ft = "k8s_*" },
        },
        opts = {
            statusline = {
                enabled = true,
            },
        },
        version = "2.*",
    },
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
