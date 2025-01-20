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
            vim.schedule(function()
                --
                -- Watch chezmoi files for changes in the source-path, and apply them.
                ev.on(ev.BufWritePost, function(args)
                    if args.file and args.file:match(".tmpl") then
                        return
                    end

                    vim.schedule(require("chezmoi.commands.__edit").watch)
                end, {
                    pattern = { vim.env.XDG_DATA_HOME .. "/chezmoi/home/*" },
                })

                -- Watch chezmoi files for changes in the target-path, and add them.
                ev.on(ev.BufReadPost, function()
                    vim.defer_fn(function()
                        local ok, targets = pcall(require("chezmoi.commands").list, { args = { "--include", "files", "--path-style", "absolute" } })

                        if ok then
                            ev.on(ev.BufWritePost, function(args)
                                notify.info("chezmoi: Adding changes to: " .. args.file)

                                vim.system({ "chezmoi", "add", args.file }, { text = true }):wait()
                            end, {
                                desc = "Apply chezmoi changes via 'chezmoi edit'",
                                pattern = targets,
                            })
                        end
                    end, 2000)
                end, {
                    once = true,
                })
            end)
        end,
        keys = {
            {
                "<leader>fz",
                function()
                    local results = require("chezmoi.commands").list({
                        args = {
                            "--path-style",
                            "absolute",
                            "--include",
                            "files",
                            "--exclude",
                            "externals",
                        },
                    })

                    local items = {}

                    for _, file in ipairs(results) do
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
