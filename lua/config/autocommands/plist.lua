-- Wrappers to deal with binary plist files. Translate them to XML for editing.
--
local M = {
    mapping = { ["json"] = "json", ["binary"] = "binary1", ["xml"] = "xml1" },
}

if vim.g.os == "Darwin" then

    vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
        callback = function(args)
            vim.cmd.doautocmd("BufReadPre")
            --
            M.read_command(args)

            local levels = vim.o.undolevels
            vim.o.undolevels = -1
            vim.cmd("silent 1delete")
            vim.o.undolevels = levels

            vim.cmd.doautocmd("BufReadPost")
        end,
        pattern = "*.plist",
    })

    vim.api.nvim_create_autocmd({ "FileReadCmd" }, {
        callback = function(args)
            vim.cmd.doautocmd("FileReadPre")
            --
            M.read_command(args)
            vim.cmd.doautocmd("FileReadPost " .. args.file)
        end,
        pattern = "*.plist",
        nested = true,
    })

    vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
        callback = function(args)
            vim.cmd.doautocmd("BufWritePre")
            M.write_command(args)
        end,
        pattern = "*.plist",
        nested = true,
    })

    vim.api.nvim_create_autocmd({ "FileWriteCmd" }, {
        callback = function(args)
            vim.cmd.doautocmd("FileWritePre")
            M.write_command(args)
        end,
        pattern = "*.plist",
        nested = true,
    })
end

M.read_command = function(args)
    --
    local bufnr = args.buf

    if not vim.uv.fs_stat(args.file) then
        vim.cmd.doautocmd("BufNewFile " .. args.file)
        return
    end

    vim.b.plist_original_format = M.detect_format(args.file)

    if vim.b.plist_original_format ~= "binary" then
        vim.cmd.bdelete("#")
        vim.cmd.file(args.file)
        vim.cmd.edit({ bang = true })

        return
    end

    require("plenary.job")
        :new({
            command = "plutil",
            args = {
                "-convert",
                "xml1",
                "-r",
                args.file,
                "-o",
                "-",
            },

            on_stderr = vim.schedule_wrap(function(_, data)
                vim.notify("read stderr: " .. vim.inspect(data))
            end),

            on_stdout = vim.schedule_wrap(function(_, data)
                vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { data })
            end),

            on_exit = vim.schedule_wrap(function()
                vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, {})

                vim.bo[bufnr].buftype = ""
                vim.bo[bufnr].filetype = "xml"
                vim.bo[bufnr].modifiable = true
                vim.bo[bufnr].modified = false
                vim.bo[bufnr].readonly = false
                vim.opt_local.wrap = false
            end),
        })
        :start()

    vim.notify(string.format("%s, %dB [%s]", args.file, vim.fn.getfsize(args.file), vim.b.plist_original_format))
end

M.write_command = function(args)
    local save_format = M.mapping[vim.b.plist_original_format or vim.g.plist_save_format]

    require("plenary.job")
        :new({
            command = "plutil",
            args = {
                "-convert",
                save_format,
                "-",
                "-o",
                args.file,
            },
            writer = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false),

            on_stderr = vim.schedule_wrap(function(_, data)
                vim.notify("write stderr: " .. vim.inspect(data))
            end),

            on_stdout = vim.schedule_wrap(function(_, data)
                vim.notify("write stdout: " .. vim.inspect(data))
            end),
            on_exit = vim.schedule_wrap(function()
                vim.bo[args.buf].modifiable = true
                vim.bo[args.buf].modified = false
            end),
        })
        :start()

    return 1
end

M.detect_format = function(filename)
    local fd = vim.loop.fs_open(filename, "r", 438)

    if fd then
        local content = vim.loop.fs_read(fd, 16, 0)
        vim.loop.fs_close(fd)

        if content then
            if string.find(tostring(content), "^bplist") then
                return "binary"
            end

            if string.find(tostring(content), "^<!DOCTYPE plist") then
                return "xml"
            end
        end
    end

    return "json"
end
