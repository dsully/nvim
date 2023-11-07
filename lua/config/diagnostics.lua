local defaults = require("config.defaults")

local function sign(opts)
    vim.fn.sign_define(opts.highlight, {
        text = opts.icon,
        texthl = opts.highlight,
        numhl = opts.linehl ~= false and opts.highlight .. "Nr" or nil,
        culhl = opts.linehl ~= false and opts.highlight .. "CursorNr" or nil,
        linehl = opts.linehl ~= false and opts.highlight .. "Line" or nil,
    })
end

sign({ highlight = "DiagnosticSignError", icon = defaults.icons.error })
sign({ highlight = "DiagnosticSignWarn", icon = defaults.icons.warn })
sign({ highlight = "DiagnosticSignInfo", linehl = false, icon = defaults.icons.info })
sign({ highlight = "DiagnosticSignHint", linehl = false, icon = defaults.icons.hint })

-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#show-source-in-diagnostics
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#change-prefixcharacter-preceding-the-diagnostics-virtual-text
vim.diagnostic.config({
    float = {
        border = vim.g.border,
        focusable = true,
        header = { " Issues:" },
        max_height = math.min(math.floor(vim.o.lines * 0.3), 30),
        max_width = math.min(math.floor(vim.o.columns * 0.7), 100),
        prefix = function(diag)
            local level = vim.diagnostic.severity[diag.severity]
            local prefix = string.format("%s ", defaults.icons[level:lower()])
            return prefix, "Diagnostic" .. level:gsub("^%l", string.upper)
        end,
        source = "if_many",
        suffix = function(diag)
            if package.loaded["rulebook"] then
                return require("rulebook").hasDocs(diag) and "  " or ""
            end
        end,
    },
    underline = true,
    signs = true,
    severity_sort = true,
    update_in_insert = false, -- https://www.reddit.com/r/neovim/comments/pfk209/nvimlsp_too_fast/
})

-- https://github.com/neovim/neovim/issues/23291
if vim.fn.executable("fswatch") == 1 then
    local FSWATCH_EVENTS = {
        Created = 1,
        Updated = 2,
        Removed = 3,
        -- Renamed
        OwnerModified = 2,
        AttributeModified = 2,
        MovedFrom = 1,
        MovedTo = 3,
        -- IsFile
        IsDir = false,
        IsSymLink = false,
        PlatformSpecific = false,
        -- Link
        -- Overflow
    }

    --- @param data string
    --- @param opts table
    --- @param callback fun(path: string, event: integer)
    local function fswatch_output_handler(data, opts, callback)
        if not data then
            return
        end

        local d = vim.split(data, "%s+")
        local cpath = d[1]

        for i = 2, #d do
            if FSWATCH_EVENTS[d[i]] == false then
                return
            end
        end

        if opts.include_pattern and opts.include_pattern:match(cpath) == nil then
            return
        end

        if opts.exclude_pattern and opts.exclude_pattern:match(cpath) ~= nil then
            return
        end

        for i = 2, #d do
            local e = FSWATCH_EVENTS[d[i]]
            if e then
                callback(cpath, e)
            end
        end
    end

    local function fswatch(path, opts, callback)
        local obj = vim.system({
            "fswatch",
            "--recursive",
            "--event-flags",
            "--exclude",
            "/.git/",
            path,
        }, {
            stdout = function(err, data)
                if err then
                    error(err)
                end

                if not data then
                    return
                end

                for line in vim.gsplit(data, "\n", { plain = true, trimempty = true }) do
                    fswatch_output_handler(line, opts, callback)
                end
            end,
        })

        return function()
            obj:kill(2)
        end
    end

    require("vim.lsp._watchfiles")._watchfunc = fswatch
end
