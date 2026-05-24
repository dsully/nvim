local M = {}

-- Display order as a list of buffer names (absolute paths).
-- Persisted across restarts via the resession extension; kept in sync on every render.
---@type string[]
M.order = {}

---@param s string
---@return string
local function esc(s)
    return (s:gsub("%%", "%%%%"))
end

-- Friendly labels for non-file buffers, keyed by filetype. Extend as needed.
local SPECIAL_FT = {
    checkhealth = "Checkhealth",
    ["nvim-pack"] = "Pack",
    qf = "Quickfix",
}

---A display label for special (non-file) buffers, or nil for normal files.
---@param bufnr integer
---@return string?
local function special_name(bufnr)
    local bo = vim.bo[bufnr]
    local ft, bt = bo.filetype, bo.buftype
    local name = vim.api.nvim_buf_get_name(bufnr)

    if bt == "terminal" then
        return ((vim.b[bufnr].term_title or "Terminal"):gsub("~/.*/", ""))
    end

    if bt == "help" then
        return vim.fn.fnamemodify(name, ":t")
    end

    if SPECIAL_FT[ft] then
        return SPECIAL_FT[ft]
    end

    -- Treesitter playground / scratch query buffers.
    if ft == "query" and bt == "nofile" then
        return vim.fn.fnamemodify(name, ":.")
    end

    if name == "" then
        return "[No Name]"
    end

    return nil
end

---Listed buffers in bufnr order (matches the `<leader>N` jump indices).
---@return integer[]
local function listed()
    return vim.tbl_filter(function(b)
        return vim.bo[b].buflisted
    end, vim.api.nvim_list_bufs())
end

---Listed buffers in persisted display order; new buffers append in bufnr order,
---unnamed buffers trail at the end. Syncs `M.order` to the current named set.
---@return integer[]
local function ordered()
    local bufs = listed()
    local by_name, unnamed = {}, {}

    for _, b in ipairs(bufs) do
        local name = vim.api.nvim_buf_get_name(b)
        if name ~= "" then
            by_name[name] = by_name[name] or b
        else
            unnamed[#unnamed + 1] = b
        end
    end

    local result, seen = {}, {}

    local function take(b, name)
        result[#result + 1] = b
        seen[name] = true
    end

    for _, name in ipairs(M.order) do
        if by_name[name] and not seen[name] then
            take(by_name[name], name)
        end
    end

    for _, b in ipairs(bufs) do
        local name = vim.api.nvim_buf_get_name(b)
        if name ~= "" and not seen[name] then
            take(b, name)
        end
    end

    M.order = vim.tbl_map(vim.api.nvim_buf_get_name, result)

    vim.list_extend(result, unnamed)

    return result
end

---Disambiguate buffers sharing a basename by prepending parent directories.
---@param bufs { buf: integer, path: string }[]
---@return table<integer, { prefix: string, name: string }>
local function unique_labels(bufs)
    local out = {}
    local groups = {}

    for _, b in ipairs(bufs) do
        local name = b.path ~= "" and vim.fn.fnamemodify(b.path, ":t") or "[No Name]"
        out[b.buf] = { prefix = "", name = name }
        groups[name] = groups[name] or {}
        table.insert(groups[name], b)
    end

    for _, members in pairs(groups) do
        if #members > 1 then
            local depth = 1

            local function parent(path)
                local segs = vim.split(path, "/", { plain = true })
                local parts = {}

                for i = math.max(1, #segs - depth), #segs - 1 do
                    parts[#parts + 1] = segs[i]
                end

                return table.concat(parts, "/")
            end

            for _ = 1, 32 do
                local seen, dup = {}, false

                for _, b in ipairs(members) do
                    local key = parent(b.path)
                    if seen[key] then
                        dup = true
                    end
                    seen[key] = true
                end

                if not dup then
                    break
                end

                depth = depth + 1
            end

            for _, b in ipairs(members) do
                local p = parent(b.path)
                out[b.buf].prefix = p ~= "" and (p .. "/") or ""
            end
        end
    end

    return out
end

---Split a string into characters paired with their display width.
---@param str string
---@return { text: string, width: integer }[]
local function chars(str)
    local out = {}
    local positions = vim.str_utf_pos(str)

    for i = 1, #positions do
        local stop = positions[i + 1] and positions[i + 1] - 1 or #str
        local text = str:sub(positions[i], stop --[[@as integer]])
        out[#out + 1] = { text = text, width = vim.fn.strdisplaywidth(text) }
    end

    return out
end

---Keep display columns [from, to] (1-indexed, inclusive) across a tab's
---segments. A wide character straddling a boundary is dropped whole (no split).
---@param segs { text: string, group: string }[]
---@param from integer
---@param to integer
---@return { text: string, group: string }[]
local function slice(segs, from, to)
    local out, col = {}, 0

    for _, s in ipairs(segs) do
        local kept = {}

        for _, ch in ipairs(chars(s.text)) do
            if col + 1 >= from and col + ch.width <= to then
                kept[#kept + 1] = ch.text
            end
            col = col + ch.width
        end

        if #kept > 0 then
            out[#out + 1] = { text = table.concat(kept), group = s.group }
        end
    end

    return out
end

---@param center number Cumulative width at the right edge of the current tab.
---@param total number
---@param avail number
---@return integer left, integer right
local function interval(center, total, avail)
    local right = math.min(total, math.floor(center + 0.5 * avail))
    local left = math.max(1, right - avail + 1)
    right = left + math.min(avail, total) - 1
    return math.floor(left), math.floor(right)
end

---@return string
function M.render()
    local current = vim.api.nvim_get_current_buf()
    local bufs = {}

    for _, b in ipairs(ordered()) do
        bufs[#bufs + 1] = { buf = b, path = vim.api.nvim_buf_get_name(b), special = special_name(b) }
    end

    if #bufs == 0 then
        return "%#TabLineFill#"
    end

    local labels = unique_labels(vim.tbl_filter(function(item)
        return not item.special
    end, bufs))

    local icons = defaults.icons

    local fill = hl.get_hl_hex("TabLineFill")
    local inactive = hl.get_hl_hex("TabLine")
    local active = hl.get_hl_hex("TabLineSel")
    local comment_fg = hl.get_hl_hex("Comment").fg
    local ok_fg = hl.get_hl_hex("DiagnosticOk").fg

    local diag = {
        [vim.diagnostic.severity.ERROR] = hl.get_hl_hex("DiagnosticError").fg,
        [vim.diagnostic.severity.WARN] = hl.get_hl_hex("DiagnosticWarn").fg,
        [vim.diagnostic.severity.INFO] = hl.get_hl_hex("DiagnosticInfo").fg,
    }

    local cwd = nvim.file.cwd()

    ---@type { buf: integer, segs: { text: string, group: string }[], width: integer, left: integer }[]
    local tabs = {}
    local total = 0

    for idx, item in ipairs(bufs) do
        local b = item.buf
        local is_current = b == current
        local bg = is_current and active.bg or inactive.bg
        local base_fg = is_current and active.fg or inactive.fg

        local segs = {}

        local function seg(text, fg, extra)
            local spec = vim.tbl_extend("force", { fg = fg or base_fg, bg = bg }, extra or {})
            segs[#segs + 1] = { text = text, group = hl.group(spec) }
        end

        if idx > 1 then
            segs[#segs + 1] = {
                text = " " .. icons.separators.bar.left,
                group = hl.group({ fg = comment_fg, bg = fill.bg }),
            }
        end

        local ok, icon, icon_hl = pcall(function()
            if item.special then
                return require("mini.icons").get("filetype", vim.bo[b].filetype)
            end

            return require("mini.icons").get("file", item.path)
        end)

        if not ok then
            icon, icon_hl = nil, nil
        end

        local icon_fg = icon_hl and hl.get_hl_hex(icon_hl).fg or base_fg
        local name_fg = base_fg

        if not item.special and item.path:find(cwd, 1, true) then
            local count = vim.diagnostic.count(b)

            for _, severity in ipairs({ vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN, vim.diagnostic.severity.INFO }) do
                if (count[severity] or 0) > 0 then
                    name_fg = diag[severity]
                    break
                end
            end
        end

        local prefix = item.special and "" or labels[b].prefix
        local name = item.special or labels[b].name

        seg(" ")
        seg(icon or " ", icon_fg)
        seg(" ")
        seg(idx .. ": ", comment_fg)

        if prefix ~= "" then
            seg(prefix, comment_fg, { italic = true })
        end

        seg(name, name_fg, { bold = is_current })

        if vim.bo[b].modified then
            seg(" ")
            seg(icons.misc.modified, ok_fg, { bold = true })
        end

        seg(" ")

        local width = 0

        for _, s in ipairs(segs) do
            width = width + vim.fn.strdisplaywidth(s.text)
        end

        tabs[#tabs + 1] = { buf = b, segs = segs, width = width, left = total }
        total = total + width
    end

    local avail = vim.o.columns
    local center = total

    for _, tab in ipairs(tabs) do
        if tab.buf == current then
            center = tab.left + tab.width
            break
        end
    end

    local need_trunc = total > avail
    local marker_group = hl.group({ fg = comment_fg, bg = fill.bg })
    local left, right = 1, total

    if need_trunc then
        left, right = interval(center, total, avail - 2)
    end

    local parts = {}

    if need_trunc and left > 1 then
        parts[#parts + 1] = "%#" .. marker_group .. "#‹"
    end

    for _, tab in ipairs(tabs) do
        if not need_trunc then
            for _, s in ipairs(tab.segs) do
                parts[#parts + 1] = "%#" .. s.group .. "#" .. esc(s.text)
            end
        else
            local tab_left, tab_right = tab.left + 1, tab.left + tab.width

            if tab_right >= left and tab_left <= right then
                local from = math.max(left, tab_left) - tab.left
                local to = math.min(right, tab_right) - tab.left

                for _, s in ipairs(slice(tab.segs, from, to)) do
                    parts[#parts + 1] = "%#" .. s.group .. "#" .. esc(s.text)
                end
            end
        end
    end

    if need_trunc and right < total then
        parts[#parts + 1] = "%#" .. marker_group .. "#›"
    end

    parts[#parts + 1] = "%#TabLineFill#"
    return table.concat(parts)
end

---Focus the i-th buffer in display order.
---@param i integer
function M.focus(i)
    local b = ordered()[i]

    if b then
        vim.api.nvim_set_current_buf(b)
    end
end

---The buffer to focus after deleting `bufnr`, in display order.
---Prefers the next buffer, falling back to the previous one.
---@param bufnr integer
---@return integer?
function M.sibling(bufnr)
    local bufs = ordered()

    for i, b in ipairs(bufs) do
        if b == bufnr then
            return bufs[i + 1] or bufs[i - 1]
        end
    end
end

---Current display order as buffer names, refreshed from open buffers.
---@return string[]
function M.snapshot()
    ordered()
    return vim.deepcopy(M.order)
end

---Restore a persisted display order (resession `on_post_load`).
---@param names string[]?
function M.set_order(names)
    M.order = names or {}
    vim.cmd.redrawtabline()
end

return M
