-- Wrappers to deal with binary plist files. Translate them to XML for editing.
--
local M = {
    mapping = { ["json"] = "json", ["binary"] = "binary1", ["xml"] = "xml1" },
    pattern = "*.plist",
}

if vim.g.os == "Darwin" then
    local ev = require("helpers.event")

    ev.on(ev.BufReadCmd, function(args)
        vim.cmd.doautocmd(ev.BufReadPre)
        --
        M.read_command(args)

        local levels = vim.o.undolevels
        vim.o.undolevels = -1

        vim.cmd.delete({
            mods = { emsg_silent = true, silent = true },
            range = { 1 },
        })

        vim.o.undolevels = levels

        vim.cmd.doautocmd(ev.BufReadPost)
    end, {
        pattern = M.pattern,
    })

    ev.on(ev.FileReadCmd, function(args)
        vim.cmd.doautocmd(ev.FileReadPre)
        --
        M.read_command(args)
        vim.cmd.doautocmd(ev.FileReadPost .. " " .. args.file)
    end, {
        nested = true,
        pattern = M.pattern,
    })

    ev.on(ev.BufWriteCmd, function(args)
        vim.cmd.doautocmd(ev.BufWritePre)
        M.write_command(args)
    end, {
        nested = true,
        pattern = M.pattern,
    })

    ev.on(ev.FileWriteCmd, function(args)
        vim.cmd.doautocmd(ev.FileWritePre)
        M.write_command(args)
    end, {
        nested = true,
        pattern = M.pattern,
    })
end

M.read_command = function(args)
    --
    local bufnr = args.buf

    if not vim.uv.fs_stat(args.file) then
        vim.cmd.doautocmd(ev.BufNewFile .. " " .. args.file)
        return
    end

    vim.b.plist_original_format = M.detect_format(args.file)

    if vim.b.plist_original_format ~= "binary" then
        vim.cmd.bdelete("#")
        vim.cmd.edit({ args.file, mods = { keepalt = true } })

        return
    end

    local xml = vim.system({ "plutil", "-convert", "xml1", "-r", args.file, "-o", "-" }, { text = true }):wait().stdout

    if xml then
        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, vim.split(xml, "\n"))

        vim.bo[bufnr].buftype = ""
        vim.bo[bufnr].filetype = "xml.plist"
        vim.bo[bufnr].modifiable = true
        vim.bo[bufnr].modified = false
        vim.bo[bufnr].readonly = false
        vim.opt_local.wrap = false

        local size = (vim.uv.fs_stat(args.file) or {}).size or 0

        vim.notify(string.format("%s, %dB [%s]", args.file, size, vim.b.plist_original_format))
    end
end

M.write_command = function(args)
    local save_format = M.mapping[vim.b.plist_original_format or vim.g.plist_save_format]

    vim.system({ "plutil", "-convert", save_format, "-", "-o", args.file }, {
        stdin = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false),
    }):wait()

    vim.bo[args.buf].modifiable = true
    vim.bo[args.buf].modified = false

    return 1
end

M.detect_format = function(filename)
    local fd = vim.uv.fs_open(filename, "r", 438)

    if fd then
        local content = vim.uv.fs_read(fd, 16, 0)
        vim.uv.fs_close(fd)

        if content then
            if string.find(tostring(content), "^bplist") then
                return "binary"
            end

            if string.find(tostring(content), "^<!DOCTYPE plist") then
                return "xml.plist"
            end
        end
    end

    return "json.plist"
end
