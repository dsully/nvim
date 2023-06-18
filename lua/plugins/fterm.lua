-- Floating terminal.
return {
    "numToStr/FTerm.nvim",
    keys = {
        {
            "<C-\\>",
            function()
                require("FTerm").toggle()
            end,

            mode = { "n", "t" },
            desc = " Terminal",
        },
    },
    opts = {
        hl = "Terminal",
    },
}
