return {
    "vuki656/package-info.nvim",
    config = function()
        local package = require("package-info")

        package.setup()

        vim.keymap.set("n", "<leader>nu", package.update, { desc = "Package: Update package on line" })
        vim.keymap.set("n", "<leader>nd", package.delete, { desc = "Package: Delete package on line" })
        vim.keymap.set("n", "<leader>ni", package.install, { desc = "Package: Install new package" })
        vim.keymap.set("n", "<leader>nv", package.change_version, { desc = "Package: Change version of package on line" })
    end,
    event = "BufRead package.json",
}
