local map = require("helpers.keys").map
local mode = { "n", "v" }

map("/", "ms/", "Keeps jumplist after forward searching")
map("?", "ms?", "Keeps jumplist after backward searching")

-- Don't count {} as jumps for the jumplist. See https://superuser.com/a/836924/1124707
map("}", function()
    vim.cmd.normal({ args = { vim.v.count1 .. "}" }, bang = true, mods = { keepjumps = true } })
end)

map("{", function()
    vim.cmd.normal({ args = { vim.v.count1 .. "{" }, bang = true, mods = { keepjumps = true } })
end)

vim.keymap.set("n", "p", function()
    -- Remove trailing newline from the " register.
    local lines = vim.split(vim.fn.getreg('"'):gsub("\n$", ""), "\n", { plain = true })
    local count = vim.v.vcount1 or 1

    -- Position cursor at start of the paste
    for _ = 1, count do
        vim.api.nvim_put(lines, "l", true, true)
        vim.cmd.normal({ args = { "`[" }, bang = true })
    end
end, { desc = 'Paste on newline from the " register without extra newline.' })

map("Y", "y$", "Yank to clipboard", mode)
map("gY", '"*y$', "Yank until end of line to system clipboard", mode)
map("gy", '"*y', "Yank to system clipboard", mode)
map("gp", '"*p', "Paste from system clipboard", mode)

map("gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Below")
map("gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Above")

map("<leader>Y", "<cmd>%y<cr>", "Yank All Lines")

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

map("<space>n", nvim.file.edit, "New File", "n", { expr = false })

-- Open in the filetype default application (macOS)
if vim.fn.has("mac") == 1 then
    map("<space>o", function()
        if not vim.bo.buftype or vim.bo.buftype == "markdown" then
            return
        end

        local filename = nvim.file.filename()

        notify.info("Opening " .. vim.fs.basename(filename), { icon = "󰏋" })

        vim.system({ "open", filename }):wait()
    end, "Open in App")

    nvim.command("Tower", function(...)
        --
        local root = Snacks.git.get_root()

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

---Copy text to clipboard using codeblock format ```{ft}{content}```
nvim.command("CopyCodeBlock", function(opts)
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, true)

    -- Find minimum indentation
    local min_indent = math.huge

    for _, line in ipairs(lines) do
        if line:match("%S") then -- Skip empty lines
            local ws = line:match("^%s*")

            if ws then
                min_indent = math.min(min_indent, ws:len())
            end
        end
    end

    -- Dedent lines
    for i, line in ipairs(lines) do
        if line:match("%S") then
            lines[i] = line:sub(math.floor(min_indent) + 1)
        end
    end

    vim.fn.setreg("+", string.format("```%s\n%s\n```", vim.bo.filetype, table.concat(lines, "\n")))
end, { range = true })

map("<leader>cc", ":CopyCodeBlock<cr>", "Copy Code Block", "v")

-- Command Mode
map("<c-a>", "<home>", "goto start of line", "c")
map("<c-e>", "<end>", "goto end of line", "c")

return {}
