local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    vim.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath }):wait()
    vim.system({ "git", "-C", lazypath, "checkout", "tags/stable" }):wait()
end

vim.opt.runtimepath:prepend(lazypath)

-- Load file based plugins without blocking the UI.
-- Snarfed from lazyvim. Maybe this will make it to lazy.nvim
do
    local Event = require("lazy.core.handler.event")
    Event.mappings.LazyFile = { id = "LazyFile", event = "User", pattern = "LazyFile" }
    Event.mappings["User LazyFile"] = Event.mappings.LazyFile

    local events = {} ---@type {event: string, buf: number, data?: any}[]

    local load = vim.schedule_wrap(function()
        if #events == 0 then
            return
        end

        vim.api.nvim_del_augroup_by_name("lazy_file")

        ---@type table<string,string[]>
        local skips = {}
        for _, event in ipairs(events) do
            skips[event.event] = skips[event.event] or Event.get_augroups(event.event)
        end

        vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile", modeline = false })

        for _, event in ipairs(events) do
            Event.trigger({
                event = event.event,
                exclude = skips[event.event],
                data = event.data,
                buf = event.buf,
            })

            if vim.bo[event.buf].filetype then
                Event.trigger({
                    event = "FileType",
                    buf = event.buf,
                })
            end
        end

        vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })

        events = {}
    end)

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePre" }, {
        group = vim.api.nvim_create_augroup("lazy_file", { clear = true }),
        callback = function(event)
            table.insert(events, event)
            load()
        end,
    })
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
    profiling = {
        -- Enables extra stats on the debug tab related to the loader cache.
        -- Additionally gathers stats about all package.loaders
        loader = false,
        -- Track each new require in the Lazy profiling tab
        require = false,
    },
    ui = {
        border = vim.g.border,
    },
})

vim.keymap.set("n", "<leader>pi", require("lazy").show, { desc = " Plugin Info" })
vim.keymap.set("n", "<leader>pp", require("lazy").profile, { desc = " Profile Plugins" })
vim.keymap.set("n", "<leader>ps", require("lazy").sync, { desc = " Sync Plugins" })
