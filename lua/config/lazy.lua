local e = require("helpers.event")

local M = {
    lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim",
    lazy_file_events = { e.BufReadPost, e.BufNewFile, e.BufWritePre },
}

-- Properly load file based plugins without blocking the UI
function M.lazy_file()
    -- Add support for the LazyFile event
    local Event = require("lazy.core.handler.event")

    if vim.fn.argc(-1) > 0 then
        -- We'll handle delayed execution of events ourselves
        Event.mappings.LazyFile = { id = "LazyFile", event = e.User, pattern = "LazyFile" }
        Event.mappings["User LazyFile"] = Event.mappings.LazyFile
    else
        -- Don't delay execution of LazyFile events, but let lazy know about the mapping
        Event.mappings.LazyFile = { id = "LazyFile", event = M.lazy_file_events }
        Event.mappings["User LazyFile"] = Event.mappings.LazyFile
        return
    end

    local events = {} ---@type {event: string, buf: number, data?: any}[]

    local done = false
    local function load()
        if #events == 0 or done then
            return
        end

        done = true

        vim.api.nvim_del_augroup_by_name("lazy_file")

        ---@type table<string,string[]>
        local skips = {}
        for _, event in ipairs(events) do
            skips[event.event] = skips[event.event] or Event.get_augroups(event.event)
        end

        vim.api.nvim_exec_autocmds(e.User, { pattern = "LazyFile", modeline = false })

        for _, event in ipairs(events) do
            if vim.api.nvim_buf_is_valid(event.buf) then
                Event.trigger({
                    event = event.event,
                    exclude = skips[event.event],
                    data = event.data,
                    buf = event.buf,
                })
                if vim.bo[event.buf].filetype then
                    Event.trigger({
                        event = e.FileType,
                        buf = event.buf,
                    })
                end
            end
        end

        vim.api.nvim_exec_autocmds(e.CursorMoved, { modeline = false })

        events = {}
    end

    -- Schedule wrap so that nested autocmds are executed and the UI can continue rendering without blocking
    load = vim.schedule_wrap(load)

    vim.api.nvim_create_autocmd(M.lazy_file_events, {
        group = vim.api.nvim_create_augroup("lazy_file", { clear = true }),
        callback = function(event)
            table.insert(events, event)
            load()
        end,
    })
end

function M.lazy_notify()
    local notifs = {}
    local function temp(...)
        table.insert(notifs, vim.F.pack_len(...))
    end

    local orig = vim.notify
    vim.notify = temp

    local timer = vim.loop.new_timer()
    local check = assert(vim.loop.new_check())

    local replay = function()
        if timer then
            timer:stop()
        end

        check:stop()
        if vim.notify == temp then
            vim.notify = orig -- put back the original notify if needed
        end
        vim.schedule(function()
            ---@diagnostic disable-next-line: no-unknown
            for _, notif in ipairs(notifs) do
                vim.notify(vim.F.unpack_len(notif))
            end
        end)
    end

    -- Wait till vim.notify has been replaced
    check:start(function()
        if vim.notify ~= temp then
            replay()
        end
    end)

    -- Or if it took more than 500ms, then something went wrong
    if timer then
        timer:start(500, 0, replay)
    end
end

function M.bootstrap()
    if not vim.uv.fs_stat(M.lazypath) then
        vim.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", M.lazypath }):wait()
        vim.system({ "git", "-C", M.lazypath, "checkout", "tags/stable" }):wait()
    end

    vim.opt.runtimepath:prepend(M.lazypath)
end

function M.setup()
    M.bootstrap()
    M.lazy_notify()
    M.lazy_file()

    local lazy = require("lazy")

    lazy.setup({
        spec = {
            -- { import = "core" },
            { import = "plugins" },
            -- { import = "plugins.lang" },
        },
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
            version = false, -- always use the latest git commit
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
            loader = true,
            -- Track each new require in the Lazy profiling tab
            require = false,
        },
        ui = {
            border = vim.g.border,
        },
    })

    vim.api.nvim_create_user_command("LazyHealth", function()
        vim.cmd.Lazy({ "load all", bang = true })
        vim.cmd.checkhealth()
    end, { desc = "Load all plugins and run :checkhealth" })

    vim.keymap.set("n", "<leader>ph", vim.cmd.LazyHealth, { desc = " Plugin Health" })
    vim.keymap.set("n", "<leader>pi", lazy.show, { desc = " Plugin Info" })
    vim.keymap.set("n", "<leader>pp", lazy.profile, { desc = " Profile Plugins" })
    vim.keymap.set("n", "<leader>ps", lazy.sync, { desc = " Sync Plugins" })
end

return M
