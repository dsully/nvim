-- Wrappers to deal with binary plist files. Translate them to XML for editing.
if vim.fn.has("mac") == 0 then
    return
end

local pattern = "*.plist"
local mapping = { ["json"] = "json", ["binary"] = "binary1", ["xml"] = "xml1" }

---@param filename string
---@return string
local detect_format = function(filename)
    local fd = vim.uv.fs_open(filename, "r", 438)

    if fd then
        local content = vim.uv.fs_read(fd, 16, 0)
        vim.uv.fs_close(fd)

        if content then
            if string.find(tostring(content), "^bplist") then
                return "binary"
            end

            if string.find(tostring(content), "^%s*[{%[]") then
                return "json"
            end
        end
    end

    return "xml"
end

---@param args vim.api.keyset.create_autocmd.callback_args
local read_command = function(args)
    local bufnr = args.buf

    if not vim.uv.fs_stat(args.file) then
        vim.cmd.doautocmd("BufNewFile " .. args.file)
        return
    end

    local format = detect_format(args.file)
    vim.b[bufnr].plist_original_format = format

    if format == "binary" then
        local xml = vim.system({ "plutil", "-convert", "xml1", "-r", args.file, "-o", "-" }, { text = true }):wait().stdout

        if xml then
            vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, vim.split(xml, "\n"))

            local size = (vim.uv.fs_stat(args.file) or {}).size or 0

            vim.notify(string.format("%s, %dB [%s]", args.file, size, format))
        end
    else
        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, vim.fn.readfile(args.file))
    end

    vim.bo[bufnr].buftype = ""
    vim.bo[bufnr].filetype = format == "json" and "json" or "xml.plist"
    vim.bo[bufnr].modifiable = true
    vim.bo[bufnr].modified = false
    vim.bo[bufnr].readonly = false
    vim.opt_local.wrap = false
end

---@param args vim.api.keyset.create_autocmd.callback_args
---@return integer
local write_command = function(args)
    local save_format = mapping[vim.b[args.buf].plist_original_format or vim.g.plist_save_format or "xml"]

    local result = vim.system({ "plutil", "-convert", save_format, "-", "-o", args.file }, {
        stdin = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false),
        text = true,
    }):wait()

    if result.code ~= 0 then
        vim.notify("plutil: " .. (result.stderr ~= "" and result.stderr or result.stdout), vim.log.levels.ERROR)
        return 0
    end

    vim.bo[args.buf].modifiable = true
    vim.bo[args.buf].modified = false

    return 1
end

vim.api.nvim_create_autocmd("BufReadCmd", {
    callback = function(args)
        vim.cmd.doautocmd("BufReadPre")

        read_command(args)

        local levels = vim.o.undolevels
        vim.o.undolevels = -1

        vim.cmd.delete({
            mods = { emsg_silent = true, silent = true },
            range = { 1 },
        })

        vim.o.undolevels = levels

        vim.cmd.doautocmd("BufReadPost")
    end,
    pattern = pattern,
})

vim.api.nvim_create_autocmd("FileReadCmd", {
    callback = function(args)
        vim.cmd.doautocmd("FileReadPre")

        read_command(args)
        vim.cmd.doautocmd("FileReadPost " .. args.file)
    end,
    nested = true,
    pattern = pattern,
})

vim.api.nvim_create_autocmd({ "BufWriteCmd", "FileWriteCmd" }, {
    callback = function(args)
        local pre, post = "BufWritePre", "BufWritePost"

        if args.event == "FileWriteCmd" then
            pre, post = "FileWritePre", "FileWritePost"
        end

        vim.cmd.doautocmd(pre)
        write_command(args)
        vim.cmd.doautocmd(post)
    end,
    nested = true,
    pattern = pattern,
})
