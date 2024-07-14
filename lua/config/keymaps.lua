local map = require("helpers.keys").map

vim.keymap.set({ "n", "x" }, "Y", "y$", { desc = "Yank to clipboard" })
-- vim.keymap.set({ "n", "x" }, "gY", '"*y$', { desc = "Yank until end of line to system clipboard" })
-- vim.keymap.set({ "n", "x" }, "gy", '"*y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "x" }, "gp", '"*p', { desc = "Paste from system clipboard" })

map("gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Below")
map("gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Above")

map("<leader>Y", "<cmd>%y<cr>", "Yank All Lines")

-- Set Ctrl-W to delete a word in insert mode
map("<C-w>", "<C-o>diw", "Delete Word", { mode = "i" })

-- Create/edit file within the current directory
map("<localleader>e", function()
    return vim.ui.input({ prompt = "Save as: " }, function(name)
        if name then
            vim.cmd.edit(("%s/%s"):format(vim.fs.dirname(vim.api.nvim_buf_get_name(0)), name))
        end
    end)
end, "Create relative to current buffer", { expr = false })

-- Close floating windows
map("<leader>fq", vim.cmd.fclose, "Close all floating windows")

-- Open in the filetype default application (macOS)
if vim.g.os == "Darwin" then
    map("<leader>o", function()
        local filename = vim.api.nvim_buf_get_name(0)

        vim.notify("󰏋 Opening " .. vim.fs.basename(filename))

        vim.system({ "open", filename }):wait()
    end, "Open in App")
end

-- Common misspellings
vim.cmd.cnoreabbrev("qw", "wq")
vim.cmd.cnoreabbrev("Wq", "wq")
vim.cmd.cnoreabbrev("WQ", "wq")
vim.cmd.cnoreabbrev("Qa", "qa")
vim.cmd.cnoreabbrev("Bd", "bd")
vim.cmd.cnoreabbrev("bD", "bd")

map("<space>s", function()
    if vim.o.spell then
        vim.opt.spell = false
    else
        vim.opt.spelloptions = { "camel", "noplainbuffer" }
        vim.opt.spell = true
    end
end, "Toggle spell check")

map("zg", function()
    require("helpers.spelling").add_word_to_typos(vim.fn.expand("<cword>"))
end, "Add word to spell list")

-- Copy text to clipboard using codeblock format ```{ft}{content}```
vim.api.nvim_create_user_command("CopyCodeBlock", function(opts)
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, true)

    vim.fn.setreg("+", string.format("```%s\n%s\n```", vim.bo.filetype, table.concat(lines, "\n")))

    vim.notify("Text copied to clipboard")
end, { range = true })

map("<leader>cb", vim.cmd.CopyCodeBlock, "Copy code block", { mode = { "n", "x" } })
