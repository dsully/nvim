---@type LazySpec[]
return {
    {
        "vuki656/package-info.nvim",
        config = function()
            local package = require("package-info")

            package.setup()

            keys.map("<leader>nu", package.update, "Package: Update package on line")
            keys.map("<leader>nd", package.delete, "Package: Delete package on line")
            keys.map("<leader>ni", package.install, "Package: Install new package")
            keys.map("<leader>nv", package.change_version, "Package: Change version of package on line")
        end,
        event = "BufRead package.json",
    },
}
