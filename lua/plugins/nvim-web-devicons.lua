return {
    "nvim-tree/nvim-web-devicons",
    init = function()
        require("lazy.core.loader").disable_rtp_plugin("nvim-web-devicons")
    end,
    opts = {
        default = true,
        override = {
            brewfile = {
                icon = "🍺",
                name = "Brewfile",
            },
        },
    },
}
