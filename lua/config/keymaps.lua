-- Quitting / Sessions
vim.keymap.set("n", "q!", function()
    vim.cmd.quitall({ bang = true })
end, { desc = "Quit without saving" })

-- Disable recording / annoying exmode.
-- https://stackoverflow.com/questions/1527784/what-is-vim-recording-and-how-can-it-be-disabled
vim.keymap.set("n", "q", "<Nop>", { desc = "which_key_ignore" })
vim.keymap.set("n", "Q", "<Nop>", { desc = "which_key_ignore" })
vim.keymap.set("n", "q:", "<Nop>", { desc = "which_key_ignore" })

vim.keymap.set({ "n", "x" }, "Y", "y$", { desc = "Yank to clipboard" })
-- vim.keymap.set({ "n", "x" }, "gY", '"*y$', { desc = "Yank until end of line to system clipboard" })
-- vim.keymap.set({ "n", "x" }, "gy", '"*y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "x" }, "gp", '"*p', { desc = "Paste from system clipboard" })

vim.keymap.set("n", "<leader>Y", "<cmd>%y<cr>", { desc = "Yank All Lines" })

-- Don't delete into the system clipboard.
vim.keymap.set({ "n", "x" }, "dw", '"_dw', { desc = "which_key_ignore", noremap = true })

-- Create/edit file within the current directory
vim.keymap.set("n", "<localleader>e", function()
    return vim.ui.input({ prompt = "Save as: " }, function(name)
        if name then
            vim.cmd.edit(("%s/%s"):format(vim.fs.dirname(vim.api.nvim_buf_get_name(0)), name))
        end
    end)
end, { silent = true, expr = false, desc = "Create relative to current buffer" })

-- Close floating windows [Neovim 0.10 and above]
vim.keymap.set("n", "<leader>fq", vim.cmd.fclose, { silent = true, desc = "Close all floating windows" })

vim.keymap.set("n", "<leader>g/", [[/^\(|||||||\|=======\|>>>>>>>\|<<<<<<<\)<CR>]], { desc = "Search for conflict markers" })

-- Open in the filetype default application (macOS)
if vim.g.os == "Darwin" then
    vim.keymap.set("n", "<leader>o", function()
        local filename = vim.api.nvim_buf_get_name(0)

        vim.notify("󰏋 Opening " .. vim.fs.basename(filename))

        vim.system({ "open", filename }):wait()
    end, { desc = "󰏋 Open in App" })
end

-- Common misspellings
vim.cmd.cnoreabbrev("qw", "wq")
vim.cmd.cnoreabbrev("Wq", "wq")
vim.cmd.cnoreabbrev("WQ", "wq")
vim.cmd.cnoreabbrev("Qa", "qa")
vim.cmd.cnoreabbrev("Bd", "bd")
vim.cmd.cnoreabbrev("bD", "bd")
