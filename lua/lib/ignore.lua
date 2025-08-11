local M = {}

---@return vim.Diagnostic?
local function diagnostic_at_cursor()
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diagnostics = vim.diagnostic.get(0, { lnum = cursor_line })

    for _, diagnostic in ipairs(diagnostics) do
        if diagnostic.source and diagnostic.code then
            return diagnostic
        end
    end
end

---@param line string
---@return string
local function indentation(line)
    return line:match("^(%s*)") or ""
end

---@param cursor_line integer
---@param delta integer
---@param line string
---@param code (string|integer)?
---@return boolean
local function replace(cursor_line, delta, line, code)
    vim.api.nvim_buf_set_lines(0, cursor_line, cursor_line + delta, false, { line })

    vim.notify("Added: " .. code, vim.log.levels.INFO)

    return true
end

---@param diagnostic vim.Diagnostic
---@param cursor_line integer
---@param line string
---@return boolean
local function handle_python_lint(diagnostic, cursor_line, line)
    if line:match("%s*#%s*noqa") then
        vim.notify("Line already has noqa comment", vim.log.levels.WARN)
        return false
    end

    return replace(cursor_line, 1, (line .. "  # noqa: " .. diagnostic.code), diagnostic.code)
end

---@param diagnostic vim.Diagnostic
---@param cursor_line integer
---@param line string
---@return boolean
local function handle_python_type(diagnostic, cursor_line, line)
    if line:match("%s*#%s*type:%s*ignore") then
        vim.notify("Line already has type ignore comment", vim.log.levels.WARN)
        return false
    end

    local ignore_comment
    local type = diagnostic.source == "basedpyright" and "pyright" or "type"

    if diagnostic.code then
        ignore_comment = string.format("  # %s: ignore[" .. diagnostic.code .. "]", type)
    else
        ignore_comment = string.format("  # %s: ignore", type)
    end

    return replace(cursor_line, 1, (line .. ignore_comment), diagnostic.code)
end

---@param diagnostic vim.Diagnostic
---@param cursor_line integer
---@param line string
---@return boolean
local function handle_fish(diagnostic, cursor_line, line)
    if line:match("%s*#%s@fish%-lsp%-disable%-next%-line") then
        vim.notify("Line already has diagnostic disable comment", vim.log.levels.WARN)
        return false
    end

    local indent = indentation(line)
    local ignore_comment = indent .. "# @fish-lsp-disable-next-line " .. diagnostic.code

    return replace(cursor_line, 0, ignore_comment, diagnostic.code)
end

---@param diagnostic vim.Diagnostic
---@param cursor_line integer
---@param line string
---@return boolean
local function handle_lua(diagnostic, cursor_line, line)
    if line:match("%s*%-%-%-@diagnostic%s+disable%-next%-line") then
        vim.notify("Line already has diagnostic disable comment", vim.log.levels.WARN)
        return false
    end

    local indent = indentation(line)
    local ignore_comment = indent .. "---@diagnostic disable-next-line: " .. diagnostic.code

    return replace(cursor_line, 0, ignore_comment, diagnostic.code)
end

---@param diagnostic vim.Diagnostic
---@param cursor_line integer
---@param line string
---@return boolean
local function handle_rust(diagnostic, cursor_line, line)
    local indent = indentation(line)
    local attribute

    if diagnostic.source == "clippy" then
        attribute = indent .. "#[allow(clippy::" .. diagnostic.code .. ")]"
    else
        attribute = indent .. "#[allow(" .. diagnostic.code .. ")]"
    end

    local existing_lines = vim.api.nvim_buf_get_lines(0, cursor_line - 1, cursor_line, false)

    ---@diagnostic disable-next-line: param-type-not-match, need-check-nil
    if #existing_lines > 0 and existing_lines[1]:match("^%s*#%[.*allow.*%]") then
        vim.notify("Line above already has allow attribute", vim.log.levels.WARN)
        return false
    end

    return replace(cursor_line, 0, attribute, diagnostic.code)
end

local handlers = {
    ["fish-lsp"] = handle_fish,
    ["rust-analyzer"] = handle_rust,
    basedpyright = handle_python_type,
    clippy = handle_rust,
    emmylua = handle_lua,
    jedi = handle_python_type,
    pyrefly = handle_python_type,
    ruff = handle_python_lint,
    rustc = handle_rust,
    ty = handle_python_type,
    zubanls = handle_python_type
}

function M.ignore()
    local diagnostic = diagnostic_at_cursor()

    if not diagnostic then
        vim.notify("No diagnostic found at cursor", vim.log.levels.WARN)
        return
    end

    -- TODO: group multiple diagnostics from the same source.
    -- for path in Path("diags/incidents").iterdir():
    --   log: dict[str, Any] = json.loads(path.read_text())  # pyright: ignore[reportAny]
    local source = diagnostic.source

    if source then
        local handler = handlers[source:lower()]

        if not handler then
            vim.notify("Unsupported diagnostic source: " .. diagnostic.source, vim.log.levels.WARN)
            return
        end

        local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1
        local line = vim.api.nvim_buf_get_lines(0, cursor_line, cursor_line + 1, false)[1]

        if not line then
            return
        end

        if not handler(diagnostic, cursor_line, line) then
            vim.notify("Failed to add ignore for diagnostic", vim.log.levels.ERROR)
        end
    end
end

return M
