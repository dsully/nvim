-- https://github.com/ThePrimeagen/refactoring.nvim ?
return {
    "yarospace/dev-tools.nvim",
    ---@type Config
    opts = {
        actions = {},

        filetypes = {
            include = { "lua", "python", "rust" },
            exclude = {},
        },

        builtin_actions = {
            include = {},
            exclude = {},
        },

        override_ui = true, -- override vim.ui.select with dev-tools actions picker
        debug = false, -- extra debug info on errors
        cache = true, -- cache actions at startup
    },
}
