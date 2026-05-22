local state = require("lib.pack.state")

local M = {}

---@param plugin PackInterfacePlugin
---@return boolean
function M.is_pending(plugin)
    return plugin.rev ~= nil and plugin.rev_to ~= nil and plugin.rev ~= plugin.rev_to
end

local function sort_by_name(items)
    table.sort(items, function(a, b)
        return a.spec.name < b.spec.name
    end)
end

function M.set_plugins(plugins)
    state.plugins = plugins
    state.pending = {}
    state.clean = {}
    state.not_loaded = {}

    for _, plugin in ipairs(state.plugins) do
        if M.is_pending(plugin) then
            state.pending[#state.pending + 1] = plugin
        end

        if not plugin.active then
            state.not_loaded[#state.not_loaded + 1] = plugin
        elseif not M.is_pending(plugin) then
            state.clean[#state.clean + 1] = plugin
        end
    end

    sort_by_name(state.plugins)
    sort_by_name(state.pending)
    sort_by_name(state.clean)
    sort_by_name(state.not_loaded)
end

---@param plugin PackInterfacePlugin
function M.replace_plugin(plugin)
    local name = plugin.spec.name

    for i, existing in ipairs(state.plugins) do
        if existing.spec.name == name then
            state.plugins[i] = plugin
            M.set_plugins(state.plugins)
            return
        end
    end

    state.plugins[#state.plugins + 1] = plugin
    M.set_plugins(state.plugins)
end

function M.reset_data()
    state.plugins = {}
    state.pending = {}
    state.clean = {}
    state.not_loaded = {}
    state.commits = {}
    state.expanded = {}
    state.line_to_name = {}
    state.name_to_line = {}
    state.line_to_commit = {}
end

function M.load_fast_plugin_list()
    local ok, plugins_or_err = pcall(vim.pack.get, nil, { info = false })

    if ok then
        M.set_plugins(plugins_or_err)
        return
    end

    state.status = tostring(plugins_or_err)
end

---@param name string
---@return PackInterfacePlugin?
function M.plugin_by_name(name)
    for _, plugin in ipairs(state.plugins) do
        if plugin.spec.name == name then
            return plugin
        end
    end
end

return M
