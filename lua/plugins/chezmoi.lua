local M = {
    targets = {},
}

-- Collect the list of targets that can be applied.
---@param callback function(string[])?
---@return vim.SystemObj
M.collect = function(callback)
    --
    return vim.system({ "chezmoi", "list", "--include", "files", "--path-style", "absolute", "--exclude", "externals" }, { text = true }, function(obj)
        --
        M.targets = vim.split(obj.stdout, "\n")

        if callback then
            vim.schedule(function()
                callback(M.targets)
            end)
        end
    end)
end

---@type LazySpec
return {
    {
        "xvzc/chezmoi.nvim",
        cmd = {
            "ChezmoiEdit",
            "ChezmoiList",
        },
        config = function()
            --
            --
            -- Watch chezmoi files for changes in the source-path, and apply them.
            ev.on(ev.BufWritePost, function()
                vim.schedule(require("chezmoi.commands.__edit").watch)
            end, {
                pattern = { vim.fs.joinpath(vim.env.XDG_DATA_HOME .. "/chezmoi/home/*") },
            })

            M.collect(function(targets)
                --
                ev.on(ev.BufWritePost, function(args)
                    notify.info("Adding changes to: " .. args.file, { title = "chezmoi" })

                    vim.system({ "chezmoi", "add", args.file }, { detach = true })
                end, {
                    desc = "Apply chezmoi changes via 'chezmoi edit'",
                    pattern = targets,
                })
            end)
        end,
        event = ev.LazyFile,
        keys = {
            {
                "<leader>fx",
                function()
                    local items = {}

                    if vim.tbl_isempty(M.targets) then
                        M.targets = vim.split(M.collect(function() end):wait().stdout or "", "\n")
                    end

                    for _, file in ipairs(M.targets) do
                        table.insert(items, {
                            text = file,
                            file = file,
                        })
                    end

                    ---@type snacks.picker.Config
                    Snacks.picker.pick({
                        confirm = function(picker, item)
                            picker:close()
                            require("chezmoi.commands").edit({
                                targets = { item.text },
                                args = { "--watch" },
                            })
                        end,
                        items = items,
                    })
                end,
                desc = "Chezmoi",
            },
        },
        opts = {},
    },
    {
        "echasnovski/mini.icons",
        optional = true,
        opts = {
            file = {
                [".chezmoiignore"] = { glyph = "", hl = "MiniIconsGrey" },
                [".chezmoiremove"] = { glyph = "", hl = "MiniIconsGrey" },
                [".chezmoiroot"] = { glyph = "", hl = "MiniIconsGrey" },
                [".chezmoiversion"] = { glyph = "", hl = "MiniIconsGrey" },
                ["fish.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
                ["json.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
                ["sh.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
                ["toml.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
                ["yaml.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },
            },
        },
    },
}
