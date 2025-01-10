-- https://github.com/neovim/neovim/pull/24044
vim.loader.enable()

-- stylua: ignore
do
    _G.dd = function(...) require("snacks.debug").inspect(...) end
    _G.bt = function(...) require("snacks.debug").backtrace(...) end
    _G.p = function(...) require("snacks.debug").profile(...) end

    vim.print = _G.dd
end

if vim.env.PROF or vim.env.PROFILE or vim.env.NVIM_PROFILE then
    local snacks = vim.fs.joinpath(tostring(vim.fn.stdpath("data")), "lazy/snacks.nvim")

    vim.opt.runtimepath:append(snacks)

    require("snacks.profiler").startup({
        startup = {
            -- Stop profiler on this event. Defaults to `VimEnter`
            event = "User",
            pattern = "VeryLazy",
        },
    })
end

require("config.options")
require("config.globals")
require("config.lazy").setup()
