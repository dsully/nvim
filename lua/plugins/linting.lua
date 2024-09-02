return {
    "mfussenegger/nvim-lint",
    config = function()
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

        if vim.g.os == "Linux" then
            lint.linters_by_ft["systemd"] = { "systemd-analyze" }
        end

        ev.on({ ev.BufEnter, ev.BufReadPost, ev.BufWritePost, ev.TextChanged, ev.InsertLeave }, function(args)
            -- Ignore 3rd party code.
            if args.file:match("/(node_modules|__pypackages__|site_packages|cargo/registry)/") then
                return
            end

            if not require("helpers.file").is_large_file(args.bufnr) then
                lint.try_lint()
                lint.try_lint("typos")
            end
        end, {
            group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        })
    end,
    event = ev.LazyFile,
}
