---@class PackInterfacePluginSpec
---@field name string
---@field src? string
---@field version? string|table

---@class PackInterfacePlugin
---@field active boolean
---@field path string
---@field rev string?
---@field rev_to string?
---@field spec PackInterfacePluginSpec

---@class PackInterfaceState
---@field bufnr integer?
---@field winid integer?
---@field autocmd integer?
---@field check_timer uv.uv_timer_t?
---@field check_dot_count integer
---@field checking boolean
---@field check_id integer
---@field status string
---@field plugins PackInterfacePlugin[]
---@field pending PackInterfacePlugin[]
---@field clean PackInterfacePlugin[]
---@field not_loaded PackInterfacePlugin[]
---@field commits table<string, string[]>
---@field expanded table<string, boolean>
---@field line_to_name table<integer, string>
---@field name_to_line table<string, integer>
---@field line_to_commit table<integer, string>

---@type PackInterfaceState
local state = {
    bufnr = nil,
    winid = nil,
    autocmd = nil,
    check_timer = nil,
    check_dot_count = 0,
    checking = false,
    check_id = 0,
    status = "",
    plugins = {},
    pending = {},
    clean = {},
    not_loaded = {},
    commits = {},
    expanded = {},
    line_to_name = {},
    name_to_line = {},
    line_to_commit = {},
}

return state
