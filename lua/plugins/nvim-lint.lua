---@type LazySpec
return {
    "mfussenegger/nvim-lint",
    config = function()
        vim.schedule(function()
            local lint = require("lint")

            lint.linters["markdownlint-cli2"].args = {
                "--config",
                nvim.file.xdg_config("/markdownlint/config.yaml"),
            }

            lint.linters.yamllint.args = {
                "--config",
                nvim.file.xdg_config("/yamllint.yaml"),
            }

            lint.linters_by_ft = defaults.linters

            if vim.fn.executable("mypy") == 1 then
                lint.linters_by_ft["python"] = { "mypy" }
            end

            if vim.fn.has("linux") then
                lint.linters_by_ft["systemd"] = { "systemd-analyze" }
            end

            -- Set up a linting toggle.
            vim.g.linting = nvim.file.is_local_dev()

            Snacks.toggle({
                name = "Linting",
                get = function()
                    return vim.g.linting
                end,
                set = function(state)
                    vim.g.linting = state
                    vim.cmd.doautocmd(ev.OptionSet)
                end,
            } --[[@as snacks.toggle.Opts]]):map("<space>tl")
        end)

        ev.on({ ev.BufReadPost, ev.BufWritePost, ev.InsertLeave, ev.OptionSet }, function(args)
            --
            if not vim.g.linting then
                return
            end

            -- Ignore buffer types and empty file types.
            if vim.tbl_contains(defaults.ignored.buffer_types, vim.bo.buftype) then
                return
            end

            if vim.tbl_contains(defaults.ignored.file_types, vim.bo.filetype) then
                return
            end

            -- Ignore 3rd party code.
            if args.file:match("/(node_modules|__pypackages__|site_packages|cargo/registry)/") then
                return
            end

            local lint = require("lint")

            lint.try_lint()
            lint.try_lint("typos")
        end, {
            group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        })
    end,
    event = ev.LazyFile,
}
