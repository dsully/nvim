vim.opt.backup = false
vim.opt.clipboard = "unnamedplus" -- https://stackoverflow.com/questions/30691466/what-is-difference-between-vims-clipboard-unnamed-and-unnamedplus-settings
vim.opt.cmdheight = 1 -- (Disabled) A little more screen real estate.
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.expandtab = true
vim.opt.fileformats = "unix" -- force \n
vim.opt.foldenable = false
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.grepprg = "rg --engine auto --vimgrep --smart-case --hidden"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.guicursor = "a:blinkon10" -- Blink the cursor.
vim.opt.guifont = "Hack Nerd Font"
vim.opt.ignorecase = true
vim.opt.laststatus = 3 -- Global status line.
vim.opt.mouse = "vi"
vim.opt.number = false
vim.opt.pumheight = 10 -- maximum number of completion-menu items
vim.opt.sessionoptions = {
    "buffers",
    "curdir",
    "globals",
    "options",
}
vim.opt.shell = "sh" -- plugins expect bash - not fish, zsh, etc
vim.opt.shiftwidth = 4
vim.opt.signcolumn = "yes" -- Always show the gutter.
vim.opt.showbreak = ">"
vim.opt.showmatch = true -- Match brackets
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.spell = true
vim.opt.spellcapcheck = "" -- don't check for capital letters at start of sentence.
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
vim.opt.spelloptions:append({ "camel" })
vim.opt.spellsuggest = "best,9"
vim.opt.splitkeep = "screen"
vim.opt.shortmess:append({ C = true, W = true, I = true, c = true })
vim.opt.softtabstop = 4
vim.opt.termguicolors = true
vim.opt.textwidth = 160
vim.opt.updatetime = 100 -- milliseconds to write the swap file.

-- Don't create root-owned files.
if vim.env.USER == "root" then
    vim.opt.undofile = false
    vim.opt.shada = ""
else
    vim.opt.undofile = true
end

-- This order is the same as the documentation.
vim.opt.formatoptions = {
    t = false, -- Auto-wrap lines using text width value.
    c = true, -- Auto-wrap comments using 'textwidth', inserting the current comment leader automatically.
    r = true, -- Automatically insert the current comment leader after hitting <Enter> in Insert mode.
    o = false, -- Insert the current comment leader after hitting 'o' or 'O' in Normal mode.
    q = true, -- Allow formatting of comments with "gq".
    a = false, -- Automatic formatting of paragraphs. Every time text is inserted or deleted the paragraph will be reformatted.
    n = true, -- When formatting text, recognize numbered lists.
    [2] = true, -- Use the indent of the second line of a paragraph for the rest of the paragraph.
    l = true, -- Long lines are not broken in insert mode.
    [1] = true, -- Don't break a line after a one-letter word.
    j = true, -- Where it makes sense, remove a comment leader when joining lines.
}

-- Mappings --
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

-- Disable unused providers.
vim.g.loaded_node_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Disable Neovide VFX.
vim.g.neovide_cursor_trail_length = 0
vim.g.neovide_cursor_animation_length = 0

vim.g.home = vim.uv.os_homedir()
vim.g.os = vim.uv.os_uname().sysname

-- Preferences
vim.g.border = "single"

-- Flag for disabling null-ls and others for large files.
vim.g.large_file = false
vim.g.large_file_size = 1024 * 512

-- Load clipboard.vim faster.
-- This assumes I have my Linux versions of pbcopy/pbpaste.
if vim.g.os == "Darwin" then
    vim.g.clipboard = {
        name = "pbcopy",
        copy = {
            ["+"] = "pbcopy",
            ["*"] = "pbcopy",
        },
        paste = {
            ["+"] = "pbpaste",
            ["*"] = "pbpaste",
        },
        cache_enabled = false,
    }
    vim.g.opener = "open"
else
    vim.g.opener = "xdg-open"
end

-- Customize diagnostic symbols in the gutter.
local icons = {
    error = "󰅚 ",
    warn = "󰀪 ",
    info = " ",
    hint = "󰌶 ",
}

local function sign(opts)
    vim.fn.sign_define(opts.highlight, {
        text = opts.icon,
        texthl = opts.highlight,
        numhl = opts.linehl ~= false and opts.highlight .. "Nr" or nil,
        culhl = opts.linehl ~= false and opts.highlight .. "CursorNr" or nil,
        linehl = opts.linehl ~= false and opts.highlight .. "Line" or nil,
    })
end

sign({ highlight = "DiagnosticSignError", icon = icons.error })
sign({ highlight = "DiagnosticSignWarn", icon = icons.warn })
sign({ highlight = "DiagnosticSignInfo", linehl = false, icon = icons.info })
sign({ highlight = "DiagnosticSignHint", linehl = false, icon = icons.hint })

-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#show-source-in-diagnostics
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#change-prefixcharacter-preceding-the-diagnostics-virtual-text
vim.diagnostic.config({
    float = {
        border = vim.g.border,
        focusable = true,
        header = { " Issues:" },
        max_height = math.min(math.floor(vim.o.lines * 0.3), 30),
        max_width = math.min(math.floor(vim.o.columns * 0.7), 100),
        prefix = function(diag)
            local level = vim.diagnostic.severity[diag.severity]
            local prefix = string.format("%s ", icons[level:lower()])
            return prefix, "Diagnostic" .. level:gsub("^%l", string.upper)
        end,
        source = "if_many",
    },
    underline = true,
    signs = true,
    severity_sort = true,
    update_in_insert = false, -- https://www.reddit.com/r/neovim/comments/pfk209/nvimlsp_too_fast/
    virtual_text = {
        format = function(diagnostic)
            -- https://www.reddit.com/r/neovim/comments/q9dxnp/set_lsp_messages_max_width/
            return string.sub(diagnostic.message, 1, 80)
        end,
        prefix = function(diagnostic)
            for d, icon in pairs(icons) do
                if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
                    return icon
                end
            end
        end,
        source = "if_many",
        spacing = 1,
    },
})
