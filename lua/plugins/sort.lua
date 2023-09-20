return {
    "sQVe/sort.nvim",
    cmd = "Sort",
    keys = {
        {
            "go",
            vim.cmd.Sort,
            desc = "Sort lines or elements",
        },
        {
            "go",
            "<Esc><Cmd>Sort<CR>",
            mode = "v",
            desc = "Sort lines or elements",
        },
    },
    opts = {
        -- These are the defaults.
        delimiters = { ",", "|", ";", ":", "s", "t" },
    },
}
