vim.o.buflisted = false
vim.o.wrap = false
vim.o.list = false
vim.o.scrolloff = 0
vim.o.winfixheight = true
vim.o.signcolumn = "auto"
vim.o.statuscolumn = ""
vim.o.cursorline = true
vim.o.number = false
vim.o.relativenumber = false
vim.o.winhighlight = "CursorLine:Visual"

vim.keymap.set("n", "q", vim.cmd.close, { buffer = 0, desc = "Close QuickFix list" })
