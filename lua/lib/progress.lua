-- Noice "mini" style view for progress messages: bottom right, newest on top.
local M = {}

local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local interval = 80
local timeout = 2000

---@class lib.progress.Item
---@field seq integer
---@field text string
---@field title string
---@field percent integer?
---@field expires integer?

---@type table<integer|string, lib.progress.Item>
local items = {}
local seq = 0

local ns = vim.api.nvim_create_namespace("dsully.progress")
local timer = assert(vim.uv.new_timer())
local buf, win = -1, -1

---@param item lib.progress.Item
---@return [string, string?][]
local function chunks(item)
    if item.expires then
        return { { "✔ ", "ProgressSpinner" }, { item.title .. " ", "ProgressTitle" } }
    end

    local ret = {}

    if item.percent then
        local contents = item.text .. " "
        local pad = math.max(20 - vim.fn.strdisplaywidth(contents), 2) --[[@as integer]]

        ret[#ret + 1] = { (" "):rep(pad) .. contents, "ProgressBar" }
        ret[#ret + 1] = { (" (%d%%) "):format(item.percent) }
    else
        ret[#ret + 1] = { " " }
    end

    ret[#ret + 1] = { frames[math.floor(vim.uv.now() / interval) % #frames + 1] .. " ", "ProgressSpinner" }
    ret[#ret + 1] = { item.title .. " ", "ProgressTitle" }

    return ret
end

local function close()
    timer:stop()

    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
end

local function render()
    local now = vim.uv.now()
    local list = {} ---@type lib.progress.Item[]

    for id, item in pairs(items) do
        if item.expires and item.expires <= now then
            items[id] = nil
        else
            list[#list + 1] = item
        end
    end

    if #list == 0 then
        return close()
    end

    -- Windows cannot be opened or moved from the command-line window.
    if vim.fn.getcmdwintype() ~= "" then
        return
    end

    table.sort(list, function(a, b)
        return a.seq > b.seq
    end)

    local lines = {} ---@type [string, string?][][]
    local texts = {} ---@type string[]
    local width = 0

    for i, item in ipairs(list) do
        lines[i] = chunks(item)
        texts[i] = table.concat(vim.tbl_map(function(c)
            return c[1]
        end, lines[i]))
        width = math.max(width, vim.fn.strdisplaywidth(texts[i]))
    end

    local pads = vim.tbl_map(function(text)
        return width - vim.fn.strdisplaywidth(text)
    end, texts)

    if not vim.api.nvim_buf_is_valid(buf) then
        buf = vim.api.nvim_create_buf(false, true)
    end

    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    vim.api.nvim_buf_set_lines(
        buf,
        0,
        -1,
        false,
        vim.iter(ipairs(texts))
            :map(function(i, text)
                return (" "):rep(pads[i]) .. text
            end)
            :totable()
    )

    for i, line in ipairs(lines) do
        local col = pads[i]

        for _, chunk in ipairs(line) do
            if chunk[2] then
                vim.api.nvim_buf_set_extmark(buf, ns, i - 1, col, { end_col = col + #chunk[1], hl_group = chunk[2] })
            end
            col = col + #chunk[1]
        end
    end

    local config = {
        relative = "editor",
        anchor = "SE",
        row = vim.o.lines - vim.o.cmdheight - (vim.o.laststatus > 0 and 1 or 0),
        col = vim.o.columns,
        width = width,
        height = #lines,
        focusable = false,
        style = "minimal",
        border = "none",
        zindex = 10,
    }

    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_config(win, config)
    else
        config.noautocmd = true
        win = vim.api.nvim_open_win(buf, false, config)
        vim.wo[win].winblend = 30
        vim.wo[win].winhighlight = "Normal:MsgArea"
    end
end

function M.setup()
    hl.apply({
        ProgressBar = { bg = colors.black.dim, fg = colors.white.bright },
        ProgressSpinner = { fg = colors.cyan.bright },
        ProgressTitle = { fg = colors.white.bright },
    })

    ev.on(ev.Progress, function(args)
        local data = args.data
        local item = items[data.id]

        if not item then
            seq = seq + 1
            item = { seq = seq }
            items[data.id] = item
        end

        item.text = table.concat(data.text or {})
        item.title = data.title or ""
        -- The Progress event reports a missing percent as 0.
        item.percent = data.percent ~= 0 and data.percent or nil
        item.expires = data.status ~= "running" and vim.uv.now() + timeout or nil

        if not timer:is_active() then
            timer:start(0, interval, vim.schedule_wrap(render))
        end
    end)
end

return M
