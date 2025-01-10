local map = require("helpers.keys").map
local mode = { "n", "v" }

map("Y", "y$", "Yank to clipboard", mode)
map("gY", '"*y$', "Yank until end of line to system clipboard", mode)
map("gy", '"*y', "Yank to system clipboard", mode)
map("gp", '"*p', "Paste from system clipboard", mode)

map("gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Below")
map("gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Above")

map("<leader>Y", "<cmd>%y<cr>", "Yank All Lines")

-- Set Ctrl-W to delete a word in insert mode
map("<C-w>", "<C-o>diw", "Delete Word", "i")

map("<C-a>", "gg<S-v>G", "Select All")
map("<C-c>", "ciw", "Change In Word")

-- Duplicate a line and comment out the first line
map("yc", "<cmd>norm yygcc<cr>p", "Duplicate line and comment original")

-- Alt + jk to move line up/down
map("<A-j>", ":m .+1<cr>==", "Move line down")
map("<A-k>", ":m .-2<cr>==", "Move line up")
map("<A-j>", "<Esc>:m .+1<cr>==gi", "Move line down (insert mode)", "i")
map("<A-k>", "<Esc>:m .-2<cr>==gi", "Move line up (insert mode)", "i")
map("<A-j>", ":m '>+1<cr>gv=gv", "Move block down", "v")
map("<A-k>", ":m '<-2<cr>gv=gv", "Move block up", "v")

-- Search for ^[<>=] ??
-- map("<leader>fc", "/<<<<CR>", "[F]ind [C]onflicts")
map("<leader>mc", "^[<>=]", "[F]ind [C]onflicts")
map("<leader>gcu", "dd/|||<CR>0v/>>><CR>$x", "[G]it [C]onflict Choose [U]pstream")
map("<leader>gcb", "0v/|||<CR>$x/====<CR>0v/>>><CR>$x", "[G]it [C]onflict Choose [B]ase")
map("<leader>gcs", "0v/====<CR>$x/>>><CR>dd", "[G]it [C]onflict Choose [S]tashed")

map("<space>n", require("helpers.file").edit, "New File", "n", { expr = false })

-- Open in the filetype default application (macOS)
if vim.g.os == "Darwin" then
    map("<leader>o", function()
        if vim.bo.buftype ~= "markdown" then
            return
        end

        local filename = vim.api.nvim_buf_get_name(0)

        notify.info("Opening " .. vim.fs.basename(filename), { icon = "󰏋" })

        vim.system({ "open", filename }):wait()
    end, "Open in App")

    vim.api.nvim_create_user_command("Tower", function()
        --
        local root = require("helpers.file").git_root()

        if root then
            vim.system({ "/usr/bin/open", "-g", "-a", "Tower", root }):wait()
        end
    end, { desc = "Open Tower", nargs = 0 })

    map("<space>T", vim.cmd.Tower, "Open in Tower")
end

-- Common misspellings
vim.cmd.cnoreabbrev("qw", "wq")
vim.cmd.cnoreabbrev("Wq", "wq")
vim.cmd.cnoreabbrev("WQ", "wq")
vim.cmd.cnoreabbrev("Qa", "qa")
vim.cmd.cnoreabbrev("Bd", "bd")
vim.cmd.cnoreabbrev("bD", "bd")

map("zg", function()
    require("helpers.spelling").add_word_to_typos(vim.fn.expand("<cword>"))
end, "Add word to spell list")

-- Copy text to clipboard using codeblock format ```{ft}{content}```
vim.api.nvim_create_user_command("CopyCodeBlock", function(opts)
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, true)

    vim.fn.setreg("+", string.format("```%s\n%s\n```", vim.bo.filetype, table.concat(lines, "\n")))
end, { range = true })

map("<leader>cc", vim.cmd.CopyCodeBlock, "Copy Code Block", { "n", "v" })

return {}
