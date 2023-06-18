return {
    "chrishrb/gx.nvim",
    event = "VeryLazy",
    opts = function()
        if vim.g.os == "Darwin" then
            return { open_browser_args = { "--background" } }
        end
    end,
}
