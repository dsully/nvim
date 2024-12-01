-- https://github.com/neovim/neovim/pull/24044
vim.loader.enable()

---@diagnostic disable-next-line: duplicate-set-field
vim.deprecate = function() end

if vim.env.PROF or vim.env.PROFILE or vim.env.NVIM_PROFILE then
    local snacks = vim.fn.stdpath("data") .. "/lazy/snacks.nvim"

    vim.opt.rtp:append(snacks)

    require("snacks.profiler").startup({
        startup = {
            event = "VeryLazy", -- Stop profiler on this event. Defaults to `VimEnter`
        },
    })
end

require("config")
