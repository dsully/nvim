-- Modified from LazyVim :)

---@class helpers.root
---@overload fun(): string
---@return string[]
local M = setmetatable({}, {
    __call = function(m, ...)
        return m.get(...)
    end,
})

---@class Root
---@field paths string[]
---@field spec RootSpec

---@alias RootFn fun(buf: number): (string|string[])

---@alias RootSpec string[]|RootFn

---@type RootSpec[]
M.spec = {
    { "lsp" },
    { ".git", "lua" },
    { "cwd" },
}

M.detectors = {}

---@return string[]
function M.detectors.cwd()
    return { nvim.file.cwd() }
end

---@param buf integer
---@return string[]
function M.detectors.lsp(buf)
    local bufpath = nvim.file.filename(buf)

    ---@type string[]
    local roots = {}
    local clients = vim.lsp.get_clients({ bufnr = buf })

    clients = vim.tbl_filter(function(client)
        return not vim.tbl_contains(defaults.ignored.lsp, client.name)
    end, clients)

    for _, client in pairs(clients) do
        local workspace = client.config.workspace_folders

        for _, ws in pairs(workspace or {}) do
            roots[#roots + 1] = vim.uri_to_fname(ws.uri)
        end

        if client.root_dir then
            roots[#roots + 1] = client.root_dir
        end
    end

    return vim.tbl_filter(function(path)
        path = vim.fs.normalize(path)
        return path and bufpath:find(path, 1, true) == 1
    end, roots)
end

---@param buf integer
---@param patterns RootSpec
---@return string[]
function M.detectors.pattern(buf, patterns)
    local path = nvim.file.filename(buf) or nvim.file.cwd()

    local pattern = vim.fs.find(function(name)
        --
        for _, p in
            ipairs(patterns --[[@as table]])
        do
            if name == p then
                return true
            end

            if p:sub(1, 1) == "*" and name:find(vim.pesc(p:sub(2)) .. "$") then
                return true
            end
        end

        return false
    end, { path = path, upward = true })[1]

    return pattern and { vim.fs.dirname(pattern) } or {}
end

---@param spec RootSpec
---@return RootFn
function M.resolve(spec)
    --
    if M.detectors[spec] then
        return M.detectors[spec]
    elseif type(spec) == "function" then
        return spec
    end

    return function(buf)
        return M.detectors.pattern(buf, spec)
    end
end

---@param opts? { buf?: number, spec?: RootSpec[], all?: boolean }
---@return Root[]
function M.detect(opts)
    --
    opts = opts or {}
    opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

    local ret = {} ---@type Root[]

    for _, spec in ipairs(M.spec) do
        --
        local paths = M.resolve(spec)(opts.buf)

        paths = paths or {}
        paths = type(paths) == "table" and paths or { paths }

        local roots = {} ---@type string[]

        for _, p in ipairs(paths) do
            --
            local pp = nvim.file.realpath(p --[[@as string ]])

            if pp and not vim.tbl_contains(roots, pp) then
                roots[#roots + 1] = pp
            end
        end

        table.sort(roots, function(a, b)
            return #a > #b
        end)

        if #roots > 0 then
            ret[#ret + 1] = { spec = spec, paths = roots }

            if opts.all == false then
                break
            end
        end
    end

    return ret
end

---@return string
function M.info()
    local roots = M.detect({ all = true })
    local lines = {} ---@type string[]
    local first = true

    for _, root in ipairs(roots) do
        for _, path in ipairs(root.paths) do
            --
            lines[#lines + 1] = ("- [%s] '%s' **(%s)**"):format(
                first and "x" or " ",
                path,
                type(root.spec) == "table" and table.concat(root.spec, ", ") or root.spec
            )

            first = false
        end
    end

    ---@diagnostic disable-next-line param-type-not-match
    vim.ui
        .float({
            ft = "markdown",
            relative = "editor",
            width = 80,
            height = 10,
            row = math.floor((vim.o.lines - 10) / 2),
            col = math.floor((vim.o.columns - 80) / 2),
        }, lines)
        :show()

    local root = roots[1]

    return root ~= nil and root.paths[1] or nvim.file.cwd()
end

---@type table<number, string>
M.cache = {}

ev.on({ ev.BufEnter, ev.BufWritePost, ev.DirChanged, ev.LspAttach }, function(event)
    M.cache[event.buf] = nil
end, { group = ev.group("nvim.root.cache", true) })

-- Returns the root directory based on:
-- * LSP workspace folders
-- * LSP root_dir
-- * Root pattern of filename of the current buffer
-- * Root pattern of cwd
--
---@param opts? {normalize?:boolean, buf?:number}
---@return string
function M.get(opts)
    opts = opts or {}

    local buf = opts.buf or vim.api.nvim_get_current_buf()
    local ret = M.cache[buf]

    if not ret then
        local roots = M.detect({ all = false, buf = buf })
        local root = roots[1]

        M.cache[buf] = root and root.paths[1] or nvim.file.cwd()
    end

    return M.cache[buf]
end

return M
