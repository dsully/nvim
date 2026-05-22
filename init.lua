-- https://github.com/neovim/neovim/pull/24044
vim.loader.enable()

vim.deprecate = function() end

vim.o.cmdheight = 0

require("config.options")
require("config.globals")
-- require("config.ui2")
require("config.pack")
