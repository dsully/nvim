return {
    "trmckay/based.nvim",
    keys = {
        {
            "<C-b>",
            function()
                require("based").convert()
            end,
            mode = { "n", "x" },
            desc = "Convert to/from hex & decimal.",
        },
    },
}
