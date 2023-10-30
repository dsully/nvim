return {
    "ojroques/nvim-osc52",
    init = function()
        local function copy(lines, _)
            require("osc52").copy(table.concat(lines, "\n"))
        end

        local function paste()
            return { vim.fn.getreg("", true), vim.fn.getregtype("") }
        end

        vim.g.clipboard = {
            name = "osc52",
            copy = {
                ["+"] = copy,
                ["*"] = copy,
            },
            paste = {
                ["+"] = paste,
                ["*"] = paste,
            },
        }
    end,
    event = "VeryLazy",
    opts = {
        silent = true,
        trim = true,
    },
}
