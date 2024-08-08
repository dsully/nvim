return {
    "mfussenegger/nvim-lint",
    config = function()
        local e = require("helpers.event")
        local lint = require("lint")

        lint.linters["markdownlint-cli2"].args = {
            "--config",
            string.format("%s/markdownlint/config.yaml", vim.env.XDG_CONFIG_HOME),
        }

        lint.linters.yamllint.args = {
            "--config",
            string.format("%s/yamllint.yaml", vim.env.XDG_CONFIG_HOME),
        }

        lint.linters_by_ft = require("config.defaults").linters

        e.on({ e.BufEnter, e.BufReadPost, e.BufWritePost, e.TextChanged, e.InsertLeave }, function(args)
            -- Ignore 3rd party code.
            if args.file:match("/(node_modules|__pypackages__|site_packages|cargo/registry)/") then
                return
            end

            if not vim.g.large_file then
                lint.try_lint()
                lint.try_lint("typos")
            end
        end, {
            group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        })
    end,
    event = "LazyFile",
}
