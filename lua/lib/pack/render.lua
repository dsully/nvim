local commit = require("lib.pack.commit")
local config = require("lib.pack.config")
local plugins = require("lib.pack.plugins")
local state = require("lib.pack.state")
local window = require("lib.pack.window")

local M = {}

local ns = vim.api.nvim_create_namespace("pack_float_ui")

---@return string
local function checking_label()
    return "  checking" .. string.rep(".", math.max(1, state.check_dot_count))
end

function M.stop_check_animation()
    if state.check_timer then
        state.check_timer:stop()
        state.check_timer:close()
        state.check_timer = nil
    end

    state.check_dot_count = 0
end

function M.start_check_animation()
    M.stop_check_animation()
    state.check_dot_count = 1
    state.check_timer = vim.uv.new_timer()

    if state.check_timer then
        state.check_timer:start(350, 350, function()
            vim.schedule(function()
                if not state.checking or not window.valid_buffer() then
                    return
                end
                state.check_dot_count = state.check_dot_count % 3 + 1
                M.render()
            end)
        end)
    end
end

local function set_lines(lines, hls)
    local bufnr = window.valid_buffer()

    if not bufnr then
        return
    end

    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].modified = false

    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    for _, hl in ipairs(hls) do
        vim.api.nvim_buf_set_extmark(bufnr, ns, hl[1], hl[2], {
            end_col = hl[3],
            hl_group = hl[4],
        })
    end
end

local function build_content()
    local lines = {}
    local hls = {}
    local line_to_name = {}
    local name_to_line = {}
    local line_to_commit = {}

    local function add(text, hl)
        local row = #lines
        lines[#lines + 1] = text

        if hl then
            hls[#hls + 1] = { row, 0, #text, hl }
        end

        return row
    end

    local function add_hl(row, start_col, end_col, hl)
        hls[#hls + 1] = { row, start_col, end_col, hl }
    end

    local function mark_plugin(row, name)
        line_to_name[row + 1] = name
        name_to_line[name] = name_to_line[name] or row + 1
    end

    -- Render a single commit line with conventional-commit highlighting.
    -- Layout: "<indent><hash> <reltime padded to time_width>  <subject>".
    local function add_commit(name, hash, subject, reltime, time_width)
        local prefix = "    " .. hash .. " "
        local line = prefix

        if time_width > 0 then
            line = line .. reltime .. string.rep(" ", time_width - #reltime) .. "  "
        end

        local base = #line
        line = line .. subject

        local row = add(line)
        mark_plugin(row, name)
        line_to_commit[row + 1] = hash

        add_hl(row, 4, 4 + #hash, "PackFloatCommit")

        if reltime ~= "" then
            add_hl(row, #prefix, #prefix + #reltime, "PackFloatMuted")
        end

        local conv = commit.parse_conventional(subject)
        local dimmed = conv ~= nil and config.dimmed_commit_types[conv.type:lower()] == true

        if dimmed then
            add_hl(row, base, base + #subject, "PackFloatDimmed")
        else
            if conv then
                add_hl(row, base, base + conv.type_len, conv.breaking and "PackFloatCommitBreaking" or "PackFloatCommitType")

                if conv.scope_start and conv.scope_end then
                    add_hl(row, base + conv.scope_start - 1, base + conv.scope_end, "PackFloatCommitScope")
                end
            end

            local init = 1

            while true do
                local issue_start, issue_end = subject:find("#%d+", init)

                if not issue_start then
                    break
                end

                add_hl(row, base + issue_start - 1, base + issue_end, "PackFloatCommitIssue")
                init = issue_end + 1
            end
        end
    end

    local header = (" vim.pack  %d plugins  %d updates"):format(#state.plugins, #state.pending)

    if state.checking then
        header = header .. "  checking..."
    elseif state.status ~= "" then
        header = header .. "  " .. state.status
    end

    add(header, "PackFloatTitle")

    local help = " [r] refresh  [u] update plugin  [U] update all  [x] remove  [Enter] details  [K] open on github  [q] close"
    local help_row = add(help)

    for start_pos, end_pos in help:gmatch("()%b[]()") do
        add_hl(help_row, start_pos - 1, end_pos - 1, "PackFloatKey")
    end

    add("")

    -- Width of the relative-time column, aligned across every plugin's commits.
    local time_width = 0

    for _, plugin in ipairs(state.pending) do
        local commits = state.commits[plugin.spec.name]

        if commits then
            for i, entry in ipairs(commit.shown_commits(commits)) do
                if i > config.max_commits then
                    break
                end

                if entry.reltime then
                    time_width = math.max(time_width, #entry.reltime)
                end
            end
        end
    end

    local function add_plugin(plugin, pending)
        local name = plugin.spec.name
        local commits = state.commits[name]

        local row = add("  " .. name)
        mark_plugin(row, name)

        add_hl(row, 2, 2 + #name, pending and "PackFloatPending" or "PackFloatClean")

        if state.expanded[name] then
            add(("    path: %s"):format(plugin.path), "PackFloatMuted")
            mark_plugin(#lines - 1, name)

            add(("    src:  %s"):format(plugin.spec.src), "PackFloatMuted")
            mark_plugin(#lines - 1, name)
        end

        if pending then
            if commits == nil then
                add("    commits: loading...", "PackFloatMuted")
                mark_plugin(#lines - 1, name)
            elseif #commits == 0 then
                add("    commits: no new commits found", "PackFloatMuted")
                mark_plugin(#lines - 1, name)
            else
                local shown = commit.shown_commits(commits)

                if #shown == 0 then
                    add("    commits: no notable commits", "PackFloatMuted")
                    mark_plugin(#lines - 1, name)
                else
                    local limit = math.min(#shown, config.max_commits)

                    for i, entry in ipairs(shown) do
                        if i > limit then
                            break
                        end

                        if entry.hash then
                            add_commit(name, entry.hash, entry.subject, entry.reltime, time_width)
                        else
                            local commit_row = add("    " .. tostring(entry.raw))
                            mark_plugin(commit_row, name)
                        end
                    end

                    if #shown > limit then
                        add(("    ... %d more"):format(#shown - limit), "PackFloatMuted")
                        mark_plugin(#lines - 1, name)
                    end
                end
            end
        end
    end

    local loaded_pending = {}

    for _, plugin in ipairs(state.pending) do
        if plugin.active then
            loaded_pending[#loaded_pending + 1] = plugin
        end
    end

    add((" Updates (%d)"):format(#loaded_pending), "PackFloatSection")

    if #loaded_pending == 0 then
        add(state.checking and checking_label() or "  no pending updates", "PackFloatMuted")
    else
        for _, plugin in ipairs(loaded_pending) do
            add_plugin(plugin, true)
        end
    end

    add("")
    add((" Up to date (%d)"):format(#state.clean), "PackFloatSection")

    for _, plugin in ipairs(state.clean) do
        add_plugin(plugin, false)
    end

    add("")
    add((" Not Loaded (%d)"):format(#state.not_loaded), "PackFloatSection")

    if #state.not_loaded == 0 then
        add("  no inactive plugins", "PackFloatMuted")
    else
        for _, plugin in ipairs(state.not_loaded) do
            add_plugin(plugin, plugins.is_pending(plugin))
        end
    end

    state.line_to_name = line_to_name
    state.name_to_line = name_to_line
    state.line_to_commit = line_to_commit

    return lines, hls
end

function M.render()
    if not window.valid_buffer() then
        return
    end

    local lines, hls = build_content()
    set_lines(lines, hls)
end

return M
