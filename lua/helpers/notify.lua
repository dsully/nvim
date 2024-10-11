local notify = {}

---@param text string
---@param level integer?
---@param opts table?
local function plain(text, level, opts)
    opts = opts or {}
    opts.title = opts.title or "nvim"

    if vim.in_fast_event() then
        vim.schedule(function()
            vim.notify(text, level, opts)
        end)
    else
        vim.notify(text, level, opts)
    end
end

---@param text string
---@param opts table?
function notify.info(text, opts)
    plain(text, vim.log.levels.INFO, opts)
end

---@param text string
---@param opts table?
function notify.error(text, opts)
    plain(text, vim.log.levels.ERROR, opts)
end

---@param text string
---@param opts table?
function notify.warn(text, opts)
    plain(text, vim.log.levels.WARN, opts)
end

---@param text string
function notify.panic(text)
    error(text)
end

return notify
