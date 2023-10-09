local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    vim.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath }):wait()
    vim.system({ "git", "-C", lazypath, "checkout", "tags/stable" }):wait()
end

vim.opt.runtimepath:prepend(lazypath)

-- Load file based plugins without blocking the UI.
-- Snarfed from lazyvim. Maybe this will make it to lazy.nvim
do
    local events = {} ---@type {event: string, pattern?: string, buf: number, data?: any}[]

    local load = vim.schedule_wrap(function()
        if #events == 0 then
            return
        end

        vim.api.nvim_del_augroup_by_name("lazy_file")
        vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile", modeline = false })

        for _, event in ipairs(events) do
            vim.api.nvim_exec_autocmds(event.event, {
                pattern = event.pattern,
                modeline = false,
                buffer = event.buf,
                data = { lazy_file = true },
            })
        end
        events = {}
    end)

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePre", "BufNewFile" }, {
        group = vim.api.nvim_create_augroup("lazy_file", { clear = true }),
        callback = function(event)
            table.insert(events, event)
            load()
        end,
        once = true,
    })
end

-- Add support for the LazyFile event
local Event = require("lazy.core.handler.event")
local _event = Event._event
---@diagnostic disable-next-line: duplicate-set-field
Event._event = function(self, value)
    return value == "LazyFile" and "User LazyFile" or _event(self, value)
end

require("lazy").setup("plugins", {
    change_detection = {
        enabled = false,
        notify = false,
    },
    checker = {
        enabled = true,
        notify = false,
    },
    defaults = {
        lazy = true,
    },
    install = {
        colorscheme = { "nordfox" },
        missing = true,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "2html_plugin",
                "getscript",
                "getscriptPlugin",
                "gzip",
                "health",
                "logipat",
                "man",
                "matchit",
                "matchparen",
                "netrw",
                "netrwFileHandlers",
                "netrwPlugin",
                "netrwSettings",
                "rplugin",
                "rrhelper",
                "spellfile",
                "spellfile_plugin",
                "tar",
                "tarPlugin",
                "tohtml",
                "tutor",
                "vimball",
                "vimballPlugin",
                "zip",
                "zipPlugin",
            },
        },
    },
    ui = {
        border = vim.g.border,
    },
})

vim.keymap.set("n", "<leader>pi", require("lazy").show, { desc = " Plugin Info" })
vim.keymap.set("n", "<leader>pp", require("lazy").profile, { desc = " Profile Plugins" })
vim.keymap.set("n", "<leader>ps", require("lazy").sync, { desc = " Sync Plugins" })
