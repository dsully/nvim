return {
    "linrongbin16/gitlinker.nvim",
    keys = {
        {
            "<leader>gc",
            function()
                return require("gitlinker").get_buf_range_url("n")
            end,
            desc = "Copy Git URL",
        },
        {
            "<leader>go",
            function()
                return require("gitlinker").get_buf_range_url("n", {
                    action_callback = function(url)
                        vim.system({ vim.g.opener, "--background", url })
                    end,
                })
            end,
            desc = "Open Git URL",
        },
    },
    opts = {
        opts = {
            print_url = false,
        },
    },
}
