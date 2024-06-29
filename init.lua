-- https://github.com/neovim/neovim/pull/24044
vim.loader.enable()

---@diagnostic disable-next-line: duplicate-set-field
vim.deprecate = function() end

require("config")
