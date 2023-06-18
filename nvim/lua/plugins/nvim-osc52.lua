return {
    "ojroques/nvim-osc52",
    cond = function()
        return vim.env.SSH_CONNECTION ~= nil and vim.env.SSH_CONNECTION ~= ""
    end,
    config = function(_, opts)
        require("osc52").setup(opts)

        local function copy(lines, _)
            require("osc52").copy(table.concat(lines, "\n"))
        end

        local function paste()
            return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
        end

        vim.g.clipboard = {
            name = "osc52",
            copy = { ["+"] = copy, ["*"] = copy },
            paste = { ["+"] = paste, ["*"] = paste },
        }
    end,
    event = "VeryLazy",
    opts = {
        silent = true,
    },
}
