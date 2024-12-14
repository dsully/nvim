return {
    "xvzc/chezmoi.nvim",
    cmd = {
        "ChezmoiEdit",
        "ChezmoiList",
    },
    init = function()
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
            end, 500)
        end, {
            once = true,
        })

        vim.api.nvim_create_user_command("ChezmoiFzf", function()
            require("fzf-lua").fzf_exec(require("chezmoi.commands").list({}), {
                actions = {
                    ["default"] = function(selected, _opts)
                        require("chezmoi.commands").edit({
                            targets = { vim.env.HOME .. selected[1] },
                            args = { "--watch" },
                        })
                    end,
                },
            })
        end, { desc = "Chezmoi Fzf" })
    end,
    opts = {},
}
