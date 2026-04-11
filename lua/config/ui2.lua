vim.o.cmdheight = 0

local ui2 = require("vim._core.ui2")

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

ev.on(ev.FileType, function()
    local ui2 = require("vim._core.ui2")
    local win = ui2.wins and ui2.wins.msg
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_option_value("winhighlight", "Normal:NormalFloat,FloatBorder:FloatBorder", { scope = "local", win = win })
    end
end, { pattern = "msg" })

local msgs = require("vim._core.ui2.messages")

local orig_set_pos = msgs.set_pos

---@param tgt? 'cmd'|'dialog'|'msg'|'pager'
msgs.set_pos = function(tgt)
    orig_set_pos(tgt)

    if vim.api.nvim_win_is_valid(ui2.wins.msg) then
        pcall(vim.api.nvim_win_set_config, ui2.wins.msg, {
            relative = "editor",
            anchor = "NE",
            row = 1,
            col = vim.o.columns - 1,
            border = "rounded",
        })
    end
end
