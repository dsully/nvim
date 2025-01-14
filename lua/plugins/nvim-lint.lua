---@type LazySpec
return {
    "mfussenegger/nvim-lint",
    cond = function()
        return require("helpers.file").is_local_dev()
    end,
    config = function()
        vim.schedule(function()
            local lint = require("lint")

            lint.linters["markdownlint-cli2"].args = {
                "--config",
                string.format("%s/markdownlint/config.yaml", vim.env.XDG_CONFIG_HOME),
            }

            lint.linters.yamllint.args = {
                "--config",
                string.format("%s/yamllint.yaml", vim.env.XDG_CONFIG_HOME),
            }

            lint.linters_by_ft = defaults.linters

            if vim.fn.executable("mypy") == 1 then
                lint.linters_by_ft["python"] = { "mypy" }
            end

            if vim.g.os == "Linux" then
                lint.linters_by_ft["systemd"] = { "systemd-analyze" }
            end
        end)

        ev.on(
            { ev.BufReadPost, ev.BufWritePost, ev.InsertLeave },
            require("helpers.debounce").debounce(100, function(args)
                --
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
            end),
            {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
            }
        )
    end,
    event = ev.LazyFile,
}
