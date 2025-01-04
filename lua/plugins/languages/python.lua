return {
    {
        "Davidyz/inlayhint-filler.nvim",
        ft = "python",
        keys = {
            {
                "<leader>i",
                function()
                    require("inlayhint-filler").fill()
                end,
                desc = "Insert the inlay-hint under cursor into the buffer.",
                mode = { "n", "x" },
            },
        },
    },
}
