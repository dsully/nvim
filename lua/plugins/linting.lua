return {
    "mfussenegger/nvim-lint",
    config = function()
        local lint = require("lint")

        lint.linters.markdownlint.args = {
            function()
                return string.format("--config=%s/markdownlint/config.yaml", vim.env.XDG_CONFIG_HOME)
            end,
        }

        lint.linters.yamllint.args = {
            function()
                return string.format("--config=%s/yamllint.yaml", vim.env.XDG_CONFIG_HOME)
            end,
        }

        lint.linters_by_ft = require("config.defaults").linters

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
    event = "LazyFile",
}
