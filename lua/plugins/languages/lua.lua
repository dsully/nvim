---@type LazySpec[]
return {
    {
        "folke/lazydev.nvim",
        cmd = "LazyDev",
        cond = false,
        ft = "lua",
        opts = {
            integrations = {
                cmp = false,
                lspconfig = false,
            },
            library = {
                { path = "blink.nvim", words = { "blink" } },
                { path = "lazy.nvim", words = { "LazyConfig", "LazySpec", "package" } },
                { path = "snacks.nvim", words = { "Snacks", "snacks" } },
                { path = "which-key.nvim", words = { "wk" } },
            },
        },
    },
    {
        "Saghen/blink.cmp",
        optional = true,
        opts = {
            sources = {
                default = { "lazydev" },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- Make lazydev completions top priority
                        score_offset = 100,
                    },
                },
            },
        },
    },
}
