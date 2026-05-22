local plugins = require("lib.pack.plugins")
local render = require("lib.pack.render")
local state = require("lib.pack.state")
local window = require("lib.pack.window")

local M = {}

---@return string[]
local function split_lines(text)
    local lines = {}

    for line in (text or ""):gmatch("[^\n]+") do
        lines[#lines + 1] = line
    end

    return lines
end

local function load_commits(plugin, check_id)
    local name = plugin.spec.name
    state.commits[name] = nil

    vim.system({
        "git",
        "-C",
        plugin.path,
        "log",
        "--format=%h%x09%s%x09%cr",
        plugin.rev .. ".." .. plugin.rev_to,
    }, { text = true }, function(result)
        vim.schedule(function()
            if state.check_id ~= check_id or not window.valid_buffer() then
                return
            end

            state.commits[name] = result.code == 0 and split_lines(result.stdout) or {}

            render.render()
        end)
    end)
end

local function finish_refresh(check_id, failures)
    if state.check_id ~= check_id or not window.valid_buffer() then
        return
    end

    render.stop_check_animation()
    state.checking = false
    state.status = failures > 0 and ("ready, %d fetch failed"):format(failures) or "ready"
    render.render()
end

local function refresh_local()
    vim.schedule(function()
        local ok, plugins_or_err = pcall(vim.pack.get, nil, { offline = false } --[[@as vim.pack.keyset.get ]])

        if not ok then
            state.status = tostring(plugins_or_err)
            render.render()
            return
        end

        state.commits = {}
        plugins.set_plugins(plugins_or_err)
        state.status = "ready"
        render.render()

        for _, plugin in ipairs(state.pending) do
            load_commits(plugin, state.check_id)
        end
    end)
end

-- vim.pack.get reports only the current `rev`, never the target it would update
-- to, so resolve it from git after a fetch (mirroring vim.pack: a pinned
-- branch/tag/commit, else the default-branch tip via origin/HEAD).
-- The target is only returned when it is strictly ahead of the current HEAD;
-- otherwise the plugin is up to date (FETCH_HEAD/tags can point at an older
-- ref, which would otherwise show as a phantom update with no new commits).
-- Semver ranges (non-string `version`) are skipped to avoid false positives.
---@param plugin PackInterfacePlugin
---@return string?
local function resolve_target(plugin)
    local function git(...)
        local out = vim.system({ "git", "-C", plugin.path, ... }, { text = true }):wait()
        return out.code == 0 and vim.trim(out.stdout or "") or nil
    end

    local version = plugin.spec.version
    local target

    if version == nil then
        target = git("rev-parse", "--verify", "--quiet", "origin/HEAD") or git("rev-parse", "--verify", "--quiet", "FETCH_HEAD")
    elseif type(version) == "string" then
        target = git("rev-parse", "--verify", "--quiet", "origin/" .. version) or git("rev-parse", "--verify", "--quiet", version)
    end

    if not target then
        return nil
    end

    local ahead = git("rev-list", "--count", "HEAD.." .. target)

    if ahead and tonumber(ahead) and tonumber(ahead) > 0 then
        return target
    end

    return nil
end

local function refresh_fetch_async()
    if state.checking then
        return
    end

    state.checking = true
    state.status = "fetching remotes"
    state.check_id = state.check_id + 1
    local check_id = state.check_id
    local total = #state.plugins
    local remaining = total
    local failures = 0
    state.commits = {}

    render.start_check_animation()
    render.render()

    if total == 0 then
        finish_refresh(check_id, failures)
        return
    end

    for _, plugin in ipairs(state.plugins) do
        local name = plugin.spec.name

        vim.system({
            "git",
            "-C",
            plugin.path,
            "fetch",
            "--quiet",
            "--tags",
            "--force",
            "--recurse-submodules=yes",
            "origin",
        }, {}, function(fetch_result)
            vim.schedule(function()
                if check_id ~= check_id or not window.valid_buffer() then
                    return
                end

                if fetch_result.code ~= 0 then
                    failures = failures + 1
                else
                    local ok, plugin_data = pcall(vim.pack.get, { name }, { offline = true } --[[@as vim.pack.keyset.get]])

                    if ok and plugin_data[1] then
                        local fresh = plugin_data[1] --[[@as PackInterfacePlugin]]
                        fresh.rev_to = resolve_target(fresh)
                        plugins.replace_plugin(fresh)

                        if plugins.is_pending(fresh) then
                            load_commits(fresh, check_id)
                        end
                    else
                        failures = failures + 1
                    end
                end

                remaining = remaining - 1
                state.status = ("fetching remotes %d/%d"):format(total - remaining, total)
                render.render()

                if remaining == 0 then
                    finish_refresh(check_id, failures)
                end
            end)
        end)
    end
end

---@param fetch boolean Whether to fetch remotes (true) or read local state (false).
function M.refresh(fetch)
    if fetch then
        refresh_fetch_async()
    else
        refresh_local()
    end
end

return M
