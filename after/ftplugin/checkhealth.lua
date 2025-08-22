--- Fold the output of vim.lsp config.
vim.opt_local.foldenable = true
vim.opt_local.foldlevel = 0
vim.opt_local.foldmethod = "indent"

require("lib.keys").bmap("q", vim.cmd.bwipe, "Close")
