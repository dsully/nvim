local map = keys.map
local mode = { "n", "x" }

map("Y", "y$", "Yank to clipboard", mode)
map("gY", '"*y$', "Yank until end of line to system clipboard", mode)
map("gy", '"*y', "Yank to system clipboard", mode)
map("gp", '"*p', "Paste from system clipboard", mode)

map("gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Below")
map("gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Above")

map("<leader>Y", "<cmd>%y<cr>", "Yank All Lines")

-- Set Ctrl-W to delete a word in insert mode
map("<C-w>", "<C-o>diw", "Delete Word", "i")

map("<space>n", function()
    local cwd = vim.uv.cwd()

    return vim.ui.input({ default = cwd, prompt = "Save as: " }, function(name)
        if name then
            vim.cmd.edit(name)
        end
    end)
end, "New File", "n", { expr = false })

-- Open in the filetype default application (macOS)
if vim.g.os == "Darwin" then
    map("<leader>o", function()
        local filename = vim.api.nvim_buf_get_name(0)

        notify.info("Opening " .. vim.fs.basename(filename), { icon = "󰏋" })

        vim.system({ "open", filename }):wait()
    end, "Open in App")

    vim.api.nvim_create_user_command("Tower", function()
        local stdout = vim.system({ "git", "rev-parse", "--show-toplevel" }):wait().stdout

        if not stdout then
            notify.error("Not in a Git repository!", { icon = "󰏋" })
            return
        end

        vim.system({ "/usr/bin/open", "-g", "-a", "Tower", vim.uv.cwd() }):wait()
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

map("<leader>cc", vim.cmd.CopyCodeBlock, "Copy Code Block", { "n", "x" })
