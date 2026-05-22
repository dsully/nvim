local git = require("lib.pack.git")
local plugins = require("lib.pack.plugins")
local render = require("lib.pack.render")
local state = require("lib.pack.state")
local window = require("lib.pack.window")

local M = {}

function M.close()
    if state.autocmd then
        pcall(vim.api.nvim_del_autocmd, state.autocmd)
        state.autocmd = nil
    end

    local winid = window.valid_window()

    if winid then
        vim.api.nvim_win_close(winid, true)
    end

    state.winid = nil
    state.bufnr = nil
    state.check_id = state.check_id + 1
    state.checking = false

    render.stop_check_animation()
end

---Format a `Progress` autocmd payload (vim.pack reports `text` as chunks).
---@param data table
---@return string
local function progress_text(data)
    local chunks = type(data.text) == "table" and data.text or { tostring(data.text or "") }
    local text = table.concat(vim.tbl_map(tostring, chunks), " ")

    if type(data.percent) == "number" then
        return ("%d%% %s"):format(data.percent, text)
    end

    return text
end

local function update_plugins(names)
    if #names == 0 then
        vim.notify("vim.pack: no pending updates", vim.log.levels.INFO)
        return
    end

    state.status = "updating " .. table.concat(names, ", ")
    render.render()

    vim.schedule(function()
        -- vim.pack.update blocks, but its scheduled progress reports still fire
        -- on the loop; surface them live in the float header.
        local group = vim.api.nvim_create_augroup("PackFloatProgress", { clear = true })

        ev.on(ev.Progress, function(args)
            if not window.valid_buffer() then
                return
            end

            state.status = progress_text(args.data)
            render.render()
        end, {
            group = group,
            pattern = "vim.pack",
        }
)

        local ok, err = pcall(vim.pack.update, names, { force = true, offline = false })

        pcall(vim.api.nvim_del_augroup_by_id, group)

        if not ok then
            vim.notify("vim.pack: " .. tostring(err), vim.log.levels.ERROR)
            state.status = "update failed"
            render.render()
            return
        end

        git.refresh(false)
    end)
end

function M.update_current()
    local name = window.plugin_at_cursor()

    if not name then
        return
    end

    for _, plugin in ipairs(state.pending) do
        if plugin.spec.name == name then
            update_plugins({ name })
            return
        end
    end

    vim.notify(("vim.pack: %s has no pending update"):format(name), vim.log.levels.INFO)
end

function M.update_all()
    local names = {}

    for _, plugin in ipairs(state.pending) do
        names[#names + 1] = plugin.spec.name
    end

    update_plugins(names)
end

-- Remove the plugin under the cursor from disk. Still re-installed on the next
-- startup if it remains in the plugin spec, matching lazy.nvim's clean.
function M.delete_current()
    local name = window.plugin_at_cursor()

    if not name then
        return
    end

    if vim.fn.confirm(("Remove plugin %q from disk?"):format(name), "&Yes\n&No", 2) ~= 1 then
        return
    end

    local ok, err = pcall(vim.pack.del, { name }, { force = true })

    if not ok then
        vim.notify("vim.pack: " .. tostring(err), vim.log.levels.ERROR)
        return
    end

    git.refresh(false)
end

---@param direction integer Positive to jump to the next plugin, negative for previous.
function M.jump(direction)
    local winid = window.valid_window()

    if not winid then
        return
    end

    local row = vim.api.nvim_win_get_cursor(winid)[1]
    local rows = vim.tbl_keys(state.line_to_name)

    table.sort(rows)

    if direction > 0 then
        for _, next_row in ipairs(rows) do
            if next_row > row then
                vim.api.nvim_win_set_cursor(winid, { next_row, 0 })
                return
            end
        end

        if rows[1] then
            vim.api.nvim_win_set_cursor(winid, { rows[1], 0 })
        end
    else
        for i = #rows, 1, -1 do
            if rows[i] < row then
                vim.api.nvim_win_set_cursor(winid, { rows[i], 0 })
                return
            end
        end

        if rows[#rows] then
            vim.api.nvim_win_set_cursor(winid, { rows[#rows], 0 })
        end
    end
end

function M.toggle_details()
    local name = window.plugin_at_cursor()

    if not name then
        return
    end

    state.expanded[name] = not state.expanded[name]

    render.render()

    local winid = window.valid_window()

    if winid and state.name_to_line[name] then
        vim.api.nvim_win_set_cursor(winid, { state.name_to_line[name], 0 })
    end
end

---@param plugin PackInterfacePlugin
---@return string? The plugin's web repo URL, without a trailing `.git`.
local function repo_url(plugin)
    local src = plugin.spec.src

    if type(src) ~= "string" then
        return nil
    end

    return (src:gsub("%.git$", ""))
end

-- Open the revision under the cursor on the forge: a specific commit when the
-- cursor is on a log line, otherwise the from..to compare (or the plugin's
-- current commit) when on the plugin row.
function M.hover()
    local winid = window.valid_window()

    if not winid then
        return
    end

    local row = vim.api.nvim_win_get_cursor(winid)[1]
    local name = state.line_to_name[row]
    local plugin = name and plugins.plugin_by_name(name)

    if not plugin then
        return
    end

    local url = repo_url(plugin)

    if not url then
        return
    end

    local commit = state.line_to_commit[row]

    if commit then
        vim.ui.open(("%s/commit/%s"):format(url, commit))
    elseif plugins.is_pending(plugin) then
        vim.ui.open(("%s/compare/%s...%s"):format(url, plugin.rev, plugin.rev_to))
    elseif plugin.rev then
        vim.ui.open(("%s/commit/%s"):format(url, plugin.rev))
    end
end

return M
