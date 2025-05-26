vim.opt.autoread = true -- update file content if it has been modified on disk
vim.opt.backup = false
vim.opt.cmdheight = vim.g.noice == true and 0 or 1 -- Set to 0 if using Noice
vim.opt.completeopt = {
    "menu",
    "menuone",
    "noselect",
}
vim.opt.confirm = true
vim.opt.expandtab = true
vim.opt.exrc = true
vim.opt.fileformats = "unix" -- force \n
vim.opt.foldenable = false
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.grepprg = "rg --engine auto --vimgrep --smart-case --hidden"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.guicursor = "a:blinkon10" -- Blink the cursor.
vim.opt.guifont = "Hack Nerd Font"
vim.opt.ignorecase = true
vim.opt.laststatus = 3 -- Global status line.
vim.opt.mouse = ""
vim.opt.mousemodel = "extend"
vim.opt.mousescroll = "ver:0,hor:0" -- Disable mouse scrolling.
vim.opt.number = false
vim.opt.pumblend = 10 -- Popup blend
vim.opt.pumheight = 10 -- maximum number of completion-menu items
vim.opt.sessionoptions = {
    "buffers",
    "curdir",
    "globals",
    "options",
    "skiprtp",
}
vim.opt.shell = "sh" -- plugins expect bash - not fish, zsh, etc
vim.opt.shiftwidth = 4
vim.opt.signcolumn = "yes" -- Always show the gutter.
vim.opt.showbreak = ">"
vim.opt.showmatch = true -- Match brackets
vim.opt.smartcase = false
vim.opt.smartindent = true
vim.opt.smoothscroll = true
vim.opt.spell = false
vim.opt.spellcapcheck = "" -- don't check for capital letters at start of sentence.
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
vim.opt.spelloptions:append({ "camel", "noplainbuffer" })
vim.opt.spellsuggest = "best,9"
vim.opt.splitkeep = "screen"
vim.opt.shortmess:append({ W = true, I = true, c = true, q = true })
vim.opt.softtabstop = 4
vim.opt.termguicolors = true
vim.opt.textwidth = 160
vim.opt.ttimeout = true
vim.opt.updatetime = 100 -- milliseconds to write the swap file.
vim.opt.wildignore:append({ ".DS_Store" })

-- Don't create root-owned files.
if vim.env.USER == "root" then
    vim.opt.undofile = false
    vim.opt.shada = ""
else
    -- Modified from https://github.com/disrupted/dotfiles
    --
    -- Disable global shada; create separate shadafile for each workspace
    -- Ensures project-scoped jumplist, marks, etc.
    --
    --—@return string
    local shadafile = function()
        local cwd = vim.uv.cwd()

        if not cwd then
            return "NONE"
        end

        local config = tostring(vim.fn.stdpath("config"))
        local rel_to_config = vim.fs.relpath(config, cwd)
        local git_root = rel_to_config and config or require("helpers.file").git_root(true)

        if not git_root then
            return "NONE"
        end

        local git_uid = vim.fs.basename(git_root) .. "-" .. vim.fn.sha256(git_root):sub(1, 8)

        return vim.fn.stdpath("state") .. "/shada/" .. git_uid .. ".shada"
    end

    vim.opt.shadafile = shadafile()

    vim.opt.undofile = true
end

-- Mappings --
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Disable unused providers.
vim.g.loaded_node_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

---@type string
vim.g.os = vim.uv.os_uname().sysname

-- Health check in a floating window.
-- vim.g.health = { style = "float" }

--
vim.g.colorscheme = "nordish"

vim.g.clipboard = {
    name = "OSC 52",
    copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
        ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
        ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
}
