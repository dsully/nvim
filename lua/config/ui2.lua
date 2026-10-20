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
            progress = "msg",
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
    local win = ui2.wins and ui2.wins.msg
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_option_value("winhighlight", "Normal:NormalFloat,FloatBorder:FloatBorder", { scope = "local", win = win })
    end
end, { pattern = "msg" })

local msgs = require("vim._core.ui2.messages")

local orig_set_pos = msgs.set_pos

-- tiny-cmdline floats the cmdline, but ui2 keeps a prompt's message (e.g. confirm()) in the dialog window at the bottom.
local function attach_dialog()
    local dialog, cmd = ui2.wins.dialog, ui2.wins.cmd

    if not (vim.api.nvim_win_is_valid(dialog) and vim.api.nvim_win_is_valid(cmd)) then
        return
    end

    local cmd_cfg = vim.api.nvim_win_get_config(cmd)

    local row = cmd_cfg.row

    if vim.api.nvim_win_get_config(dialog).hide or cmd_cfg.hide or cmd_cfg.relative ~= "editor" or not row then
        return
    end

    vim.api.nvim_win_set_config(dialog, { width = cmd_cfg.width })

    local height = math.max(1, math.min(vim.api.nvim_win_text_height(dialog, {}).all, row - 2)) --[[@as integer]]

    vim.api.nvim_win_set_config(dialog, {
        relative = "editor",
        anchor = "NW",
        row = math.max(0, row - height - 2),
        col = cmd_cfg.col,
        width = cmd_cfg.width,
        height = height,
        border = cmd_cfg.border,
    })

    vim.wo[dialog].winhighlight = vim.wo[cmd].winhighlight
    -- ui2 already flushed the screen in set_pos, before the window moved.
    vim.api.nvim__redraw({ flush = true })
end

---@param tgt? 'cmd'|'dialog'|'msg'|'pager'
rawset(msgs, "set_pos", function(tgt)
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

    if tgt == nil or tgt == "dialog" then
        attach_dialog()
    end
end)

local skip_messages = {
    "%d+ more lines?",
    "%d+ lines? less",
    "%d+ fewer lines",
    "^%d+ changes?; before #%d+",
    "^%d+ changes?; after #%d+",
    "^%-%-No lines in buffer%-%-$",
    "%d+ lines yanked",
    "%d+ lines [<>]ed",
    "%d+ lines filtered",
    "Hunk %d+ of",
    "W325:",
    "Found a swap file by the name",
    "getaddrinfo",
    "vim.lsp.get_active_clients",
    "Conversion failed at step",
    "mmdc failed to render diagram",
    "unhandled notification textDocument/didSave",
}

local orig_msg_show = msgs.msg_show

---@param kind string
---@param content [integer, string, integer][]
rawset(msgs, "msg_show", function(kind, content, ...)
    -- Progress messages are drawn by lib.progress instead.
    if kind == "progress" then
        return
    end

    local text = table.concat(vim.tbl_map(function(chunk)
        return chunk[2]
    end, content))

    for _, pattern in ipairs(skip_messages) do
        if text:find(pattern) then
            return
        end
    end

    orig_msg_show(kind, content, ...)
end)

-- Noice-style cmdline formats. First match wins; patterns are matched against firstc .. cmdline.
-- firstc and the match are hidden unless conceal = false.
local cmdline_formats = {
    { pattern = { "^/" }, icon = "\u{f002} \u{f103}", lang = "regex" },
    { pattern = { "^%?" }, icon = "\u{f002} \u{f102}", lang = "regex" },
    { pattern = { "^=" }, icon = "\u{f1ec}", lang = "vim" },
    { pattern = { "^:vim%." }, icon = "\u{eab8}", hl = "Error", conceal = false },
    { pattern = { "^:Gitsigns%s+", "^:Neogit%s+", "^:GitLink%s+" }, icon = "\u{e725}", lang = "vim" },
    { pattern = { "^:Session%s+" }, icon = "\u{e6ae}", lang = "vim" },
    { pattern = { "^:%s*r!", "^:%s*!" }, icon = "$", lang = "bash" },
    { pattern = { "^:%%?s/" }, icon = "\u{ebcb}", lang = "regex" },
    { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=", "^:%s*=" }, icon = "\u{e620}", lang = "lua" },
    { pattern = { "^:%s*he?l?p?%s+" }, icon = "\u{f128}" },
    { pattern = { "^:" }, icon = "\u{f054}", lang = "vim" },
}

local cmdline = require("vim._core.ui2.cmdline")
local cmdline_ns = vim.api.nvim_create_namespace("dsully.cmdline")
local orig_cmdline_show = cmdline.cmdline_show
local orig_cmdline_pos = cmdline.cmdline_pos
local orig_cmdline_hide = cmdline.cmdline_hide

---Bytes removed from the start of the cmdline, per cmdline level.
---@type table<integer, integer>
local hidden = {}

---@param firstc string
---@param text string
local function find_format(firstc, text)
    for _, format in ipairs(cmdline_formats) do
        for _, pattern in ipairs(format.pattern) do
            local _, finish = (firstc .. text):find(pattern)

            if finish then
                return format, finish - #firstc
            end
        end
    end
end

---@param text string
---@param lang string?
---@param col integer Buffer column at which text starts.
local function highlight(text, lang, col)
    local ok, parser = pcall(vim.treesitter.get_string_parser, text, lang or "")

    if not ok then
        return
    end

    parser:parse(true)
    parser:for_each_tree(function(tstree, tree)
        local query = tstree and vim.treesitter.query.get(tree:lang(), "highlights")

        if not query then
            return
        end

        for id, node in query:iter_captures(tstree:root(), text) do
            local name = query.captures[id]

            if name and name:sub(1, 1) ~= "_" then
                local _, start_col, _, end_col = node:range()

                vim.api.nvim_buf_set_extmark(ui2.bufs.cmd, cmdline_ns, cmdline.srow, col + start_col, {
                    end_col = col + end_col,
                    hl_group = ("@%s.%s"):format(name, tree:lang()),
                    strict = false,
                })
            end
        end
    end)
end

-- The icon is passed as the prompt: ui2 then keeps the cursor after it, which inline virtual text and conceal do not.
-- hl_id is passed through unchanged, so newer Nvim does not treat the icon as an input() prompt.
-- Without an input() prompt, older Nvim sends prompt "" and hl_id 0; newer Nvim sends false and -1 (neovim/neovim@e542b42903).
local function show_cmdline(content, pos, firstc, prompt, indent, level, hl_id)
    local text = table.concat(vim.tbl_map(function(chunk)
        return chunk[2]
    end, content))
    local format, finish = find_format(firstc, text)

    if not format or not finish or (prompt and prompt ~= "") then
        hidden[level] = nil
        orig_cmdline_show(content, pos, firstc, prompt, indent, level, hl_id)
        vim.api.nvim_buf_clear_namespace(ui2.bufs.cmd, cmdline_ns, 0, -1)
        return
    end

    hidden[level] = format.conceal == false and -#firstc or finish
    text = format.conceal == false and firstc .. text or text:sub(finish + 1)
    prompt = format.icon .. " "

    orig_cmdline_show({ { 0, text } }, math.max(pos - hidden[level], 0), "", prompt, indent, level, hl_id)

    -- Older Nvim sets this from #prompt, and then routes messages to the dialog window as for input().
    cmdline.prompt = false

    vim.api.nvim_buf_clear_namespace(ui2.bufs.cmd, cmdline_ns, 0, -1)
    vim.api.nvim_buf_set_extmark(ui2.bufs.cmd, cmdline_ns, cmdline.srow, 0, {
        end_col = #format.icon,
        hl_group = format.hl or "DiagnosticSignInfo",
    })
    highlight(text, format.lang, #prompt + indent)
end

local function is_search()
    local type = vim.fn.getcmdtype()
    return type == "/" or type == "?"
end

-- ui2 sets 'cmdheight' to 1 for every cmdline. For search, keep it 0: tiny-cmdline pins search to the
-- bottom row, which is then the statusline row (like noice's bottom_search preset), so the statusline does not move.
rawset(cmdline, "cmdline_show", function(...)
    show_cmdline(...)

    if is_search() then
        vim._with({ noautocmd = true, o = { splitkeep = "screen" } }, function()
            vim.o.cmdheight = 0
        end)
    end
end)

rawset(cmdline, "cmdline_pos", function(pos, level, ...)
    orig_cmdline_pos(math.max(pos - (hidden[level] or 0), 0), level, ...)
end)

rawset(cmdline, "cmdline_hide", function(level, ...)
    hidden[level] = nil
    vim.api.nvim_buf_clear_namespace(ui2.bufs.cmd, cmdline_ns, 0, -1)
    orig_cmdline_hide(level, ...)
end)

-- Changing 'cmdheight' redraws the screen after Neovim's one-shot incsearch highlight, so search matches are drawn here.

---@class config.ui2.Search
---@field win integer
---@field hlsearch boolean 'hlsearch' when the search started.
---@field v_hlsearch integer v:hlsearch when the search started.
---@field ids integer[] Match ids in win.

---@type config.ui2.Search?
local search

---@param text string
---@param delimiter string
---@return string pattern The text before an unescaped delimiter, which starts a search offset.
local function search_pattern(text, delimiter)
    local i = 1

    while i <= #text do
        local char = text:sub(i, i)

        if char == "\\" then
            i = i + 2
        elseif char == delimiter then
            return text:sub(1, i - 1)
        else
            i = i + 1
        end
    end

    return text
end

---@param pattern string
local function with_case(pattern)
    if pattern:find("\\[cC]") then
        return pattern
    end

    local ignore = vim.o.ignorecase and not (vim.o.smartcase and pattern:find("%u"))

    return (ignore and "\\c" or "\\C") .. pattern
end

---@param state config.ui2.Search
local function clear_matches(state)
    for _, id in ipairs(state.ids) do
        pcall(vim.fn.matchdelete, id, state.win)
    end

    state.ids = {}
end

---@param state config.ui2.Search
local function add_matches(state)
    local type = vim.fn.getcmdtype()
    local text = vim.fn.getcmdline()
    local pattern = search_pattern(text, type)
    local has_offset = #pattern < #text

    if pattern == "" then
        return
    end

    pattern = with_case(pattern)

    local ok, id = pcall(vim.fn.matchadd, "Search", pattern, 10, -1, { window = state.win })

    if not ok then
        return
    end

    state.ids[#state.ids + 1] = id --[[@as integer]]

    -- Incsearch leaves the cursor at the end of the current match, but not reliably with an offset.
    if has_offset then
        return
    end

    local pos = vim.fn.searchpos(pattern, "bcnW")

    if pos[1] > 0 then
        local line = vim.fn.getline(pos[1]) --[[@as string]]
        local length = #vim.fn.matchstr(line:sub(pos[2]), pattern)

        state.ids[#state.ids + 1] = vim.fn.matchaddpos("IncSearch", { { pos[1], pos[2], math.max(length, 1) } }, 11, -1, { window = state.win }) --[[@as integer]]
    end
end

ev.on(ev.CmdlineEnter, function()
    search = {
        win = vim.api.nvim_get_current_win(),
        hlsearch = vim.o.hlsearch,
        v_hlsearch = vim.v.hlsearch,
        ids = {},
    }

    -- Hide the matches of the previous search while typing. v:hlsearch does not work: incsearch restores it.
    vim.o.hlsearch = false
end, {
    desc = "Start drawing search matches",
    pattern = { "/", "?" },
})

local function refresh_matches()
    if search and is_search() then
        clear_matches(search)
        add_matches(search)
    end
end

ev.on(ev.CmdlineChanged, refresh_matches, {
    desc = "Draw search matches",
    pattern = { "/", "?" },
})

-- CTRL-G and CTRL-T move to another match without a change to the cmdline, so CmdlineChanged does not fire.
vim.on_key(function(key)
    if search and (key == "\7" or key == "\20") then
        vim.schedule(function()
            refresh_matches()

            if search then
                vim.api.nvim__redraw({ win = search.win, flush = true })
            end
        end)
    end
end, vim.api.nvim_create_namespace("dsully.search_keys"))

ev.on(ev.CmdlineLeave, function()
    if not search then
        return
    end

    clear_matches(search)

    -- Setting 'hlsearch' also sets v:hlsearch to 1, so restore both. A completed search sets v:hlsearch after this.
    vim.o.hlsearch = search.hlsearch
    vim.v.hlsearch = search.v_hlsearch

    search = nil
end, {
    desc = "Stop drawing search matches",
    pattern = { "/", "?" },
})

require("lib.progress").setup()

ev.on(ev.LspProgress, function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local value = args.data.params.value
    local title = value.title or ""

    if not client or vim.tbl_contains(defaults.ignored.progress, client.name) or title:find("cargo clippy") then
        return
    end

    vim.api.nvim_echo({ { value.message or "" } }, false, {
        id = ("lsp.%d.%s"):format(client.id, tostring(args.data.params.token)),
        kind = "progress",
        percent = value.percentage,
        source = "vim.lsp",
        status = value.kind == "end" and "success" or "running",
        title = title,
    })
end)
