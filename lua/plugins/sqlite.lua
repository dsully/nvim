return {
    "kkharji/sqlite.lua",
    build = function()
        vim.fn.mkdir(vim.fn.stdpath("data") .. "/databases", "p")
    end,
}
