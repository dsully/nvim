---@type LazySpec[]
return {
    {
        "folke/lazydev.nvim",
        cmd = "LazyDev",
        ft = "lua",
        opts = {
            integrations = {
                cmp = false,
                lspconfig = false,
            },
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                { path = "${3rd}/busted/library", words = { "describe" } },
                { path = "${3rd}/luassert/library", words = { "assert" } },
                { path = "lazy.nvim", words = { "LazySpec", "package" } },
                { path = "noice.nvim" },
                { path = "snacks.nvim", words = { "Snacks" } },
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
