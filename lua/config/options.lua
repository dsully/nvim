vim.o.autoread = true -- update file content if it has been modified on disk
vim.o.backup = false
vim.o.cmdheight = 0 -- Set to 0 if using Noice
vim.o.completeopt = "menu,menuone,noselect"
vim.o.confirm = true
vim.o.expandtab = true
vim.o.exrc = true
vim.o.fileformats = "unix" -- force \n
vim.o.foldenable = false
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.grepprg = "rg --engine auto --vimgrep --smart-case --hidden"
vim.o.grepformat = "%f:%l:%c:%m"
vim.o.guicursor = "a:blinkon10" -- Blink the cursor.
vim.o.guifont = "Hack Nerd Font"
vim.o.ignorecase = true
vim.o.laststatus = 3 -- Global status line.
vim.o.mouse = ""
vim.o.mousemodel = "extend"
vim.o.mousescroll = "ver:0,hor:0" -- Disable mouse scrolling.
vim.o.number = false
vim.o.pumblend = 10 -- Popup blend
vim.o.pumheight = 10 -- maximum number of completion-menu items
vim.o.sessionoptions = "buffers,curdir,globals,options,skiprtp"
vim.o.shell = "sh" -- plugins expect bash - not fish, zsh, etc
vim.o.shiftwidth = 4
vim.o.signcolumn = "yes" -- Always show the gutter.
vim.o.showbreak = ">"
vim.o.showmatch = true -- Match brackets
vim.o.smartcase = false
vim.o.smartindent = true
vim.o.smoothscroll = true
vim.o.spell = false
vim.o.spellcapcheck = "" -- don't check for capital letters at start of sentence.
vim.o.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
vim.o.spelloptions = "camel,noplainbuffer"
vim.o.spellsuggest = "best,9"
vim.o.splitkeep = "screen"
vim.o.shortmess = vim.o.shortmess .. "WIcq"
vim.o.softtabstop = 4
vim.o.termguicolors = true
vim.o.textwidth = 160
vim.o.ttimeout = true
vim.o.ttimeoutlen = 0
vim.o.updatetime = 100 -- milliseconds to write the swap file.
-- vim.o.wildignore:append({ ".DS_Store" })

-- Don't create root-owned files.
if vim.env.USER == "root" then
    vim.o.undofile = false
    vim.o.shada = ""
else
    -- Loading shada is SLOW, load it manually, after UI-enter so it doesn't block startup.
    local shada = vim.o.shada

    vim.o.shada = ""

    vim.api.nvim_create_autocmd("User", {
        callback = function(...)
            vim.o.shada = shada
            pcall(vim.cmd.rshada, { bang = true })
        end,
        pattern = "LazyDone",
    })

    vim.o.undofile = true
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

vim.g.home = vim.uv.os_homedir()
vim.g.os = vim.uv.os_uname().sysname

-- Health check in a floating window.
-- vim.g.health = { style = "float" }

--
vim.g.colorscheme = "nordish"

vim.g.ts_path = vim.fs.joinpath(tostring(vim.fn.stdpath("data")), "ts-install")

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

-- Work around: https://github.com/neovim/neovim/issues/31675
vim.hl = vim.highlight

---@diagnostic disable-next-line: duplicate-set-field
vim.deprecate = function() end
