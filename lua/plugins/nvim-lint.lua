return {
    "mfussenegger/nvim-lint",
    config = function()
        local config = vim.env.XDG_CONFIG_HOME

        local lint = require("lint")
        local linters = lint.linters

        linters.gitlint = {
            cmd = "gitlint",
            stdin = true,
            args = {
                string.format("--config=%s/gitlint.ini", config),
                "--msg-filename",
                "-",
            },
            stream = "stderr",
            ignore_exitcode = true,
            env = nil,
            parser = require("lint.parser").from_pattern([[(%d+): (%w+) (.+)]], { "lnum", "code", "message" }),
        }

        linters.markdownlint.args = {
            function()
                return string.format("--config=%s/markdownlint/config.yaml", config)
            end,
        }

        linters.yamllint.args = {
            function()
                return string.format("--config=%s/yamllint.yaml", config)
            end,
        }

        lint.linters_by_ft = {
            bash = { "shellcheck" },
            c = {},
            cpp = {},
            fish = { "fish" },
            ghaction = { "actionlint" },
            gitcommit = { "gitlint", "write_good" },
            go = { "revive" },
            htmldjango = { "curlylint" },
            java = {},
            jinja = { "curlylint" },
            json = {},
            lua = {},
            markdown = { "markdownlint", "write_good" },
            protobuf = { "protolint" },
            python = {}, -- "mypy", "ruff"
            rst = { "rstcheck", "write_good" },
            rust = {},
            sh = { "shellcheck" },
            text = { "write_good" },
            yaml = { "yamllint" },
            ["*"] = { "typos" },
        }

        vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "BufWritePost", "TextChanged", "InsertLeave" }, {
            callback = function(args)
                -- Ignore 3rd party code.
                if args.file:match("/(node_modules|__pypackages__|site_packages)/") then
                    return
                end

                if not vim.g.large_file then
                    require("lint").try_lint()
                end
            end,
            group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        })
    end,
    event = vim.g.defaults.lazyfile,
}
