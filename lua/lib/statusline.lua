local M = {}

M.diagnostic_levels = {
    { name = "ERROR", icon = defaults.icons.diagnostics.error, hl = "DiagnosticError" },
    { name = "WARN", icon = defaults.icons.diagnostics.warn, hl = "DiagnosticWarn" },
    { name = "INFO", icon = defaults.icons.diagnostics.info, hl = "DiagnosticInfo" },
    { name = "HINT", icon = defaults.icons.diagnostics.hint, hl = "DiagnosticHint" },
}

-- Diagnostic counts per buffer id
---@type table<integer, table<vim.diagnostic.Severity, integer>?>
M.diagnostic_counts = {}

---@return string
function M.aerial()
    local ahl = require("aerial.highlight")
    local depth = 5
    local parts = {}

    for _, symbol in ipairs({ unpack(require("aerial").get_location(), 1, depth) }) do
        local hl_group = ahl.get_highlight(symbol, false, false)
        local name = hl_group and hl.as_string(hl_group, symbol.name) or symbol.name

        local icon_hl = ahl.get_highlight(symbol, true, false)
        local icon = icon_hl and hl.as_string(icon_hl, symbol.icon) or symbol.icon

        table.insert(parts, string.format("%s%s", icon, name))
    end

    if #parts == 0 then
        return ""
    end

    return table.concat(parts, " ⟩ ")
end

function M.counts()
    local line_percent = math.floor(100 * vim.fn.line(".") / vim.fn.line("$"))

    return table.concat({
        hl.as_string("MiniIconsBlue", " "),
        string.format("%d/%d:%-2d", vim.fn.line("."), vim.fn.line("$"), vim.fn.virtcol(".")),
        line_percent == 100 and "All" or (line_percent == 0 and "Top" or string.format("%2d%%%%", line_percent)),
    }, " ")
end

function M.diagnostics()
    local count = M.diagnostic_counts[vim.api.nvim_get_current_buf()] or {}

    local severity, parts = vim.diagnostic.severity, {}

    if vim.diagnostic.is_enabled({ bufnr = 0 }) then
        for _, level in ipairs(M.diagnostic_levels) do
            local n = count[severity[level.name]] or 0

            if n > 0 then
                table.insert(parts, hl.as_string(level.hl, level.icon) .. " " .. hl.as_string("StatusLine", n))
            end
        end

        return table.concat(parts, " ")
    end

    return ""
end

function M.fileinfo()
    if vim.bo.filetype == "" then
        return ""
    end

    local icon, icon_hl = require("mini.icons").get("filetype", vim.bo.filetype)

    if not icon or not icon_hl then
        icon, icon_hl = "󰈚", "MiniIconsGrey"
    end

    return string.format(
        " %s %s",
        hl.as_string(hl.group({ fg = hl.get_hl_hex(icon_hl).fg }), icon),
        hl.as_string(hl.group({ fg = colors.white.bright }), vim.bo.filetype)
    )
end

function M.git()
    if not vim.b.gitsigns_head then
        return ""
    end

    return hl.as_string("MiniIconsBlue", defaults.icons.git.branch) .. vim.b.gitsigns_head
end

function M.schema()
    if vim.tbl_contains({ "helm", "json", "toml", "yaml" }, vim.bo.filetype) then
        local current_schema = require("schema-companion").get_current_schemas()

        if current_schema then
            return defaults.icons.misc.table .. (current_schema or "none")
        end
    end

    return ""
end

function M.scrollbar()
    local sbar_chars = { "▔", "🮂", "🬂", "🮃", "▀", "▄", "▃", "🬭", "▂", "▁" }

    local cur_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)

    local i = math.floor((cur_line - 1) / lines * #sbar_chars) + 1
    local sbar = sbar_chars[i]

    return hl.as_string("DiagnosticInfo", " " .. sbar .. "  ")
end

-- Use `schedule_wrap()` because `redrawstatus` might error on `:bwipeout`
-- See: https://github.com/neovim/neovim/issues/32349
ev.on(
    ev.DiagnosticChanged,
    vim.schedule_wrap(function(data)
        M.diagnostic_counts[data.buf] = vim.api.nvim_buf_is_valid(data.buf) and vim.diagnostic.count(data.buf) or nil
        vim.cmd.redrawstatus()
    end),
    { desc = "Track diagnostics" }
)

return M
