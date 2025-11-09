---@type LazySpec
return {
    "age",
    config = function()
        local path = nvim.file.xdg_config("/chezmoi/chezmoi.toml")

        local identity = vim.system({ "tomlq", "-r", ".age.identity", path }, { text = true }):wait().stdout
        local recipient = vim.system({ "tomlq", "-r", ".age.recipient", path }, { text = true }):wait().stdout

        if identity ~= nil then
            identity = identity:gsub("\r?\n$", "")
        end

        if recipient ~= nil then
            recipient = recipient:gsub("\r?\n$", "")
        end

        if not identity then
            Snacks.notify.error("Could not find [age] identity in chezmoi.toml")
            return
        end

        ev.on({ ev.BufReadPost, ev.FileReadPost }, function()
            vim.cmd(string.format("silent '[,']!age --decrypt -i %s", vim.fs.normalize(identity)))

            vim.bo.binary = false

            ev.emit(ev.BufReadPost, { pattern = vim.fn.expand("%:r") })
        end, {
            desc = "Decrypt age file",
            pattern = "*.age",
        })

        ev.on({ ev.BufWritePre, ev.FileWritePre }, function()
            vim.bo.binary = true

            vim.cmd(string.format("silent '[,']!age --encrypt -r %s -a", recipient))
        end, {
            desc = "Encrypt age file",
            pattern = "*.age",
        })
    end,
    ft = "age",
    init = function()
        ev.on(ev.FileType, function()
            vim.o.backup = false
            vim.o.writebackup = false
            vim.o.shada = ""
        end, {
            pattern = "age",
        })

        ev.on({ ev.BufReadPre, ev.FileReadPre }, function()
            vim.bo.binary = true
            vim.bo.swapfile = false
            vim.bo.undofile = false
        end, {
            pattern = "age",
        })

        ev.on({ ev.BufWritePost, ev.FileWritePost }, function()
            vim.cmd.undo({ mods = { emsg_silent = true, silent = true } })
            vim.bo.binary = false
        end, { pattern = "*.age" })
    end,
    virtual = true,
}
