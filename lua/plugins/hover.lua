-- Help / hover.
return {
    "lewis6991/hover.nvim",
    keys = {
        {
            "gk",
            function()
                require("hover").hover()
            end,
            desc = "Hover Providers",
        },
    },
    opts = {
        init = function()
            -- Require providers
            require("hover.providers.dictionary")
            require("hover.providers.gh")
            require("hover.providers.gh_user")
            require("hover.providers.man")
        end,
        preview_opts = {
            border = vim.g.border,
        },
        title = false,
    },
}
