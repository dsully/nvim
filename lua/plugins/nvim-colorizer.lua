-- Colorized hex codes. This must be at BufRead to work properly.
return {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
        user_default_options = {
            names = false,
        },
    },
}
