vim.o.cmdheight = 0

local ui2 = require("vim._core.ui2")

-- ui2.enable({
--     msg = {
--         ---@type 'cmd'|'msg' Where to place regular messages, either in the
--         ---cmdline or in a separate ephemeral message window.
--         target = "msg",
--         timeout = 3000, -- Time a message is visible in the message window.
--     },
-- })

ui2.enable({
    enable = true,
    ---@type 'cmd'|'msg' Where to place regular messages, either in the
    msg = {
        targets = {
            [""] = "msg",
            empty = "cmd",
            bufwrite = "msg",
            confirm = "cmd",
            emsg = "pager",
            echo = "msg",
            echomsg = "msg",
            echoerr = "pager",
            completion = "cmd",
            list_cmd = "pager",
            lua_error = "pager",
            lua_print = "msg",
            progress = "pager",
            rpc_error = "pager",
            quickfix = "msg",
            search_cmd = "cmd",
            search_count = "cmd",
            shell_cmd = "pager",
            shell_err = "pager",
            shell_out = "pager",
            shell_ret = "msg",
            undo = "msg",
            verbose = "pager",
            wildlist = "cmd",
            wmsg = "msg",
            typed_cmd = "cmd",
        },
        cmd = {
            height = 0.5,
        },
        dialog = {
            height = 0.5,
        },
        msg = {
            height = 0.3,
            timeout = 5000,
        },
        pager = {
            height = 0.5,
        },
        timeout = 3000, -- Time a message is visible in the message window.
    },
})

-- Customize the msg window appearance.
ev.on(ev.FileType, function()
    vim.api.nvim_win_set_config(0, { border = "none" })

    vim.wo[0][0].winhighlight = "Normal:MsgArea,Search:,CurSearch:,IncSearch:"
end, {
    pattern = "msg",
})

-- LSP progress -> nvim_echo for ui2 display + Ghostty OSC 9;4 progress bar.
ev.on(ev.ColorScheme, function()
    vim.api.nvim_set_hl(0, "LspProgressClient", { fg = colors.blue.base })
    vim.api.nvim_set_hl(0, "LspProgressDone", { bg = colors.black.dim, fg = colors.white.bright })
    vim.api.nvim_set_hl(0, "LspProgressMessage", { fg = colors.white.bright })
    vim.api.nvim_set_hl(0, "LspProgressSpinner", { fg = colors.cyan.bright })
    vim.api.nvim_set_hl(0, "LspProgressTitle", { fg = colors.white.bright })
    vim.api.nvim_set_hl(0, "LspProgressTodo", { bg = colors.black.dim, fg = colors.white.bright })
end)

-- ev.on(ev.LspProgress, function(ev)
--     ---@type lsp.ProgressParams
--     local params = ev.data.params
--     local value = params.value or {}
--     local msg = value.message or "done"
--
--     -- if #msg > 40 then
--     --     msg = msg:sub(1, 37) .. "..."
--     -- end
--
--     local is_done = value.kind == "end"
--     local spinner = is_done and "✔ " or "⠋ "
--     local pct = value.percentage and ("(%d%%) "):format(value.percentage) or ""
--
--     vim.api.nvim_echo(
--         {
--             { spinner, is_done and "LspProgressDone" or "LspProgressSpinner" },
--             { (value.title or "") .. " ", "LspProgressTitle" },
--             { pct, "LspProgressMessage" },
--             { vim.trim(msg), "LspProgressMessage" },
--         },
--         false,
--         {
--             id = "lsp",
--             kind = "progress",
--             title = value.title --[[@as string?]],
--             status = is_done and "success" or "running",
--             percent = value.percentage --[[@as integer?]],
--         }
--     )
-- end)
--
-- -- In case Neovim is exiting while the LSP is still running, it will send an OSC
-- -- sequence to Ghostty to make sure the progress bar is removed.
-- ev.on({ ev.ExitPre, ev.VimLeavePre }, function()
--     if vim.env.TERM and vim.env.TERM:match("ghostty") then
--         local osc = "\27]9;4;0;100\a"
--
--         vim.api.nvim_chan_send(vim.v.stderr, osc)
--     end
-- end)

-- Workaround: nvim_open_win in check_targets can fail with E1159 when called during a
-- buffer close (e.g. session restore triggering LSP detach -> diagnostic reset -> redraw -> msg_ruler).
local orig = ui2.check_targets

ui2.check_targets = function()
    local ok, err = pcall(orig)

    if ok then
        return
    end

    if type(err) == "string" then
        if not err:find("E1159") then
            error(err)
        end

        return
    end

    error(err)
end
