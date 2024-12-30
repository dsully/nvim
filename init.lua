-- https://github.com/neovim/neovim/pull/24044
vim.loader.enable()

-- Loading shada is SLOW, so we're going to load it manually, after UI-enter so it doesn't block startup.
local shada = vim.o.shada

vim.o.shada = ""

vim.api.nvim_create_autocmd("User", {
    callback = function()
        vim.o.shada = shada
        pcall(vim.cmd.rshada, { bang = true })
    end,
    pattern = "VeryLazy",
})

-- Work around: https://github.com/neovim/neovim/issues/31675
vim.hl = vim.highlight

---@diagnostic disable-next-line: duplicate-set-field
vim.deprecate = function() end

if vim.env.PROF or vim.env.PROFILE or vim.env.NVIM_PROFILE then
    local snacks = vim.fn.stdpath("data") .. "/lazy/snacks.nvim"

    vim.opt.rtp:append(snacks)

    ---@diagnostic disable-next-line: missing-fields
    require("snacks.profiler").startup({
        startup = {
            event = "VeryLazy", -- Stop profiler on this event. Defaults to `VimEnter`
        },
    })
end

require("config")
