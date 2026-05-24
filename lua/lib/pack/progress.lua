local M = {}

---@type integer?
local restore_cmd_height = nil

local pack_path = vim.fn.stdpath("data") .. "/site/pack/core/opt"
local pack_lock = vim.fn.stdpath("config") .. "/nvim-pack-lock.json"

local function notify_missing_packs(missing)
    if #missing == 0 then
        return
    end

    if restore_cmd_height == nil and vim.o.cmdheight == 0 then
        restore_cmd_height = vim.o.cmdheight
        vim.o.cmdheight = 1
    end

    table.sort(missing)

    vim.notify("Installing plugins: " .. table.concat(missing, ", "), vim.log.levels.INFO, { title = "vim.pack" })

    vim.cmd.redraw({ bang = true })
end

function M.report_missing_lock_packs()
    local lock_data = nvim.file.read(pack_lock)

    if lock_data ~= nil and lock_data ~= "" then
        local lock = vim.json.decode(lock_data)

        if type(lock.plugins) ~= "table" then
            return
        end

        local missing = {}

        for name in pairs(lock.plugins) do
            if vim.uv.fs_stat(vim.fs.joinpath(pack_path, name)) == nil then
                missing[#missing + 1] = name
            end
        end

        notify_missing_packs(missing)
    end
end

local function pack_spec_name(spec)
    if type(spec) == "table" and spec.name then
        return spec.name
    end

    local src = type(spec) == "table" and spec.src or spec
    if type(src) ~= "string" then
        return nil
    end

    return src:gsub("%.git$", ""):match("/([^/]+)$") or src:gsub("%.git$", "")
end

local function report_missing_packs(specs)
    local missing = {}

    for _, spec in ipairs(specs) do
        local name = pack_spec_name(spec)

        if name and vim.uv.fs_stat(vim.fs.joinpath(pack_path, name)) == nil then
            missing[#missing + 1] = name
        end
    end

    notify_missing_packs(missing)
end

function M.with_pack_progress(callback)
    local add = vim.pack.add

    vim.pack.add = function(specs, opts)
        report_missing_packs(specs)
        local ok, result = pcall(add, specs, opts)

        if not ok then
            error(result)
        end

        return result
    end

    local ok, result = pcall(callback)

    vim.pack.add = add

    if restore_cmd_height ~= nil then
        vim.o.cmdheight = restore_cmd_height
        restore_cmd_height = nil
    end

    if not ok then
        error(result)
    end

    return result
end

local function progress_text(text)
    if type(text) == "string" then
        return text
    end

    if type(text) == "table" then
        return table.concat(vim.tbl_map(tostring, text), " ")
    end

    return tostring(text or "")
end

function M.setup()
    vim.o.messagesopt = vim.o.messagesopt:gsub("progress:c", "progress:")

    vim.api.nvim_create_autocmd(ev.Progress, {
        group = ev.group("PackProgress"),
        pattern = "vim.pack",
        callback = function(args)
            local data = args.data
            local level = data.status == "failed" and vim.log.levels.ERROR or vim.log.levels.INFO

            vim.notify(progress_text(data.text), level, {
                title = data.title or "vim.pack",
                id = "vim.pack.progress." .. tostring(data.id),
                timeout = data.status == "running" and false or 3000,
            })
        end,
    })
end

return M
