local actions = require("lib.pack.actions")
local git = require("lib.pack.git")
local plugins = require("lib.pack.plugins")
local render = require("lib.pack.render")
local state = require("lib.pack.state")
local window = require("lib.pack.window")

local M = {}

local function bmap(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = state.bufnr, silent = true, nowait = true, desc = desc })
end

local function setup_keymaps()
    bmap("q", actions.close, "Close")
    bmap("<Esc>", actions.close, "Close")

    bmap("r", function()
        git.refresh(true)
    end, "Refresh updates")

    bmap("u", actions.update_current, "Update plugin")
    bmap("U", actions.update_all, "Update all pending")

    bmap("x", actions.delete_current, "Remove plugin")
    bmap("c", actions.delete_current, "Remove plugin")

    bmap("<CR>", actions.toggle_details, "Toggle details")

    bmap("K", actions.hover, "Open on GitHub")
end

function M.open(opts)
    opts = opts or {}

    local existing = window.valid_window()

    if existing then
        vim.api.nvim_set_current_win(existing)
        return
    end

    state.bufnr = vim.api.nvim_create_buf(false, true)

    vim.bo[state.bufnr].buftype = "nofile"
    vim.bo[state.bufnr].bufhidden = "wipe"
    vim.bo[state.bufnr].swapfile = false
    vim.bo[state.bufnr].filetype = "pack-float"

    local columns = vim.o.columns
    local screen_lines = vim.o.lines
    local width = math.min(160, math.max(80, math.floor(columns * 0.9)))
    local height = math.max(25, math.floor(screen_lines * 0.9))

    state.winid = vim.api.nvim_open_win(state.bufnr, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((screen_lines - height) / 2),
        col = math.floor((columns - width) / 2),
        -- border = "rounded",
        title = " vim.pack ",
        title_pos = "center",
    })

    vim.wo[state.winid].cursorline = true
    vim.wo[state.winid].wrap = false

    plugins.reset_data()
    plugins.load_fast_plugin_list()
    setup_keymaps()
    render.render()

    local captured_win = state.winid

    state.autocmd = vim.api.nvim_create_autocmd("WinClosed", {
        once = true,
        callback = function(ev)
            if vim._tointeger(ev.match) == captured_win then
                state.autocmd = nil
                state.winid = nil
                state.bufnr = nil
                state.check_id = state.check_id + 1
                state.checking = false
                render.stop_check_animation()
            end
        end,
    })

    git.refresh(opts.fetch ~= false)
end

do
    for group, spec in pairs({
        PackFloatTitle = "Title",
        PackFloatBorder = "FloatBorder",
        PackFloatSection = "Label",
        PackFloatPending = "DiagnosticWarn",
        PackFloatClean = "String",
        PackFloatMuted = "Comment",
        PackFloatHash = "Number",
        PackFloatKey = "Function",
        PackFloatError = "DiagnosticError",

        -- Conventional-commit log highlighting (mirrors lazy.nvim's view).
        PackFloatCommit = "@variable.builtin", -- commit ref
        PackFloatCommitType = "Title", -- conventional type
        PackFloatCommitScope = { italic = true }, -- conventional scope
        PackFloatCommitIssue = "Number", -- #123 references
        PackFloatCommitBreaking = "DiagnosticError", -- breaking change (`!`)
        PackFloatDimmed = "Conceal", -- low-signal commit types
    }) do
        local hl = type(spec) == "table" and spec or { link = spec }
        vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", { default = true }, hl))
    end

    vim.api.nvim_create_user_command("Pack", function(command)
        M.open({ fetch = not command.bang })
    end, {
        bang = true,
        desc = "Open vim.pack UI",
    })
end

return M
