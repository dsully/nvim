return {
    "aspeddro/gitui.nvim",
    keys = {
        {
            "<space>g",
            function()
                require("gitui").open()
            end,
            desc = " Git UI",
        },
    },
    opts = {
        command = {
            enable = false,
        },
        window = {
            options = {
                border = vim.g.border,
            },
        },
    },
}
