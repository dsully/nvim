local config = require("lib.pack.config")

local M = {}

---Parse a conventional-commit subject ("type(scope)!: summary").
---@param subject string
---@return { type: string, type_len: integer, scope_start: integer?, scope_end: integer?, breaking: boolean }?
function M.parse_conventional(subject)
    local kind = subject:match("^(%a[%w_%-]*)")

    if not kind then
        return nil
    end

    local pos = #kind + 1
    local scope = subject:sub(pos):match("^(%b())")
    local scope_start, scope_end

    if scope then
        scope_start, scope_end = pos, pos + #scope - 1
        pos = pos + #scope
    end

    local breaking = subject:sub(pos, pos) == "!"

    if breaking then
        pos = pos + 1
    end

    if subject:sub(pos, pos) ~= ":" then
        return nil
    end

    return { type = kind, type_len = #kind, scope_start = scope_start, scope_end = scope_end, breaking = breaking }
end

---Parse and filter a plugin's commit lines ("hash\tsubject\treltime") into the
---entries that will be displayed (dropping dimmed types when configured).
---@param commits string[]
---@return { hash: string?, subject: string?, reltime: string?, raw: string? }[]
function M.shown_commits(commits)
    local shown = {}

    for _, entry in ipairs(commits) do
        local hash, subject, reltime = entry:match("^(%S+)\t(.-)\t(.*)$")

        if not hash then
            shown[#shown + 1] = { raw = entry }
        else
            local conv = M.parse_conventional(subject or "")
            local is_dimmed = conv ~= nil and config.dimmed_commit_types[conv.type:lower()] == true

            if not (config.hide_dimmed_commits and is_dimmed) then
                shown[#shown + 1] = { hash = hash, subject = subject, reltime = reltime or "" }
            end
        end
    end

    return shown
end

return M
