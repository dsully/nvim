return {
    "age",
    config = function()
        local fs = require("helpers.file")

        local path = vim.fs.joinpath(vim.env.XDG_CONFIG_HOME, "chezmoi", "/chezmoi.toml")
        local config = fs.read_toml(path)

        if not config then
            return
        end

        ---@class Age
        ---@field identity string
        ---@field recipient string
        local age = config.age

        if not age or not age.identity then
            notify.error("Could not find [age] identity in chezmoi.toml")
            return
        end

        ev.on({ ev.BufReadPost, ev.FileReadPost }, function()
            vim.cmd(string.format("silent '[,']!age --decrypt -i %s", vim.fs.normalize(age.identity)))

            vim.bo.binary = false

            ev.emit(ev.BufReadPost, { pattern = vim.fn.expand("%:r") })
        end, {
            desc = "Decrypt age file",
            pattern = "*.age",
        })

        ev.on({ ev.BufWritePre, ev.FileWritePre }, function()
            vim.bo.binary = true

            vim.cmd(string.format("silent '[,']!age --encrypt -r %s -a", age.recipient))
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
            vim.opt.shada = ""
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
