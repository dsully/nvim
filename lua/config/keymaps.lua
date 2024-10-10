local map = keys.map
local mode = { "n", "x" }
local toggle = keys.toggle

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

-- Close floating windows
map("<leader>fq", vim.cmd.fclose, "Close all floating windows")

-- Open in the filetype default application (macOS)
if vim.g.os == "Darwin" then
    map("<leader>o", function()
        local filename = vim.api.nvim_buf_get_name(0)

        vim.notify("󰏋 Opening " .. vim.fs.basename(filename))

        vim.system({ "open", filename }):wait()
    end, "Open in App")

    map("<space>T", function()
        local stdout = vim.system({ "git", "rev-parse", "--show-toplevel" }):wait().stdout
        local root = vim.uv.cwd()

        if stdout then
            root = vim.trim(stdout)
        else
            return vim.notify("󰏋 Not in a git repository", vim.log.levels.WARN)
        end

        vim.system({ "/usr/bin/open", "-g", "-a", "Tower", root }):wait()
    end, "Open Tower")
end

-- Common misspellings
vim.cmd.cnoreabbrev("qw", "wq")
vim.cmd.cnoreabbrev("Wq", "wq")
vim.cmd.cnoreabbrev("WQ", "wq")
vim.cmd.cnoreabbrev("Qa", "qa")
vim.cmd.cnoreabbrev("Bd", "bd")
vim.cmd.cnoreabbrev("bD", "bd")

-- Toggle options
toggle.map("<space>td", toggle.diagnostics)
toggle.map("<space>tn", toggle("number", { name = "Line Numbers" }))
toggle.map("<space>ts", toggle("spell", { name = "Spelling" }))
toggle.map("<space>tt", toggle.treesitter)
toggle.map("<space>tw", toggle("wrap", { name = "Wrap" }))

map("zg", function()
    require("helpers.spelling").add_word_to_typos(vim.fn.expand("<cword>"))
end, "Add word to spell list")

-- Copy text to clipboard using codeblock format ```{ft}{content}```
vim.api.nvim_create_user_command("CopyCodeBlock", function(opts)
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, true)

    vim.fn.setreg("+", string.format("```%s\n%s\n```", vim.bo.filetype, table.concat(lines, "\n")))
end, { range = true })

map("<leader>cc", vim.cmd.CopyCodeBlock, "Copy Code Block", { "n", "x" })

vim.api.nvim_create_user_command("Scratch", function()
    vim.cmd("bel 10new")

    local buf = vim.api.nvim_get_current_buf()

    for name, value in pairs({
        bufhidden = "wipe",
        buftype = "nofile",
        filetype = "scratch",
        modifiable = true,
        swapfile = false,
    }) do
        vim.api.nvim_set_option_value(name, value, { buf = buf })
    end
end, { desc = "Open a scratch buffer", nargs = 0 })
