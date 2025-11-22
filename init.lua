-- https://github.com/neovim/neovim/pull/24044
vim.loader.enable()

if vim.env.PROF ~= nil or vim.env.PROFILE ~= nil or vim.env.NVIM_PROFILE ~= nil then
    local snacks = vim.fs.joinpath(tostring(vim.fn.stdpath("data")), "lazy/snacks.nvim")

    vim.opt.runtimepath:append(snacks)

    require("snacks.profiler").startup({
        startup = {
            -- Stop profiler on this event. Defaults to `VimEnter`
            event = "User",
            pattern = "VeryLazy",
        },
    } --[[@as snacks.profiler.Config]])
end

vim.deprecate = function() end

require("config.options")
require("config.globals")
require("config.lazy").init()

---@type boolean?
vim.g.noice = true

if vim.g.noice == false then
    require("vim._extui").enable({ msg = { pos = "box" } })
end
