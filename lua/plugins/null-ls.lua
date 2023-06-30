-- Setup null-ls linters & formatters.

return {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
        local common = require("plugins.lsp.common")
        local null_ls = require("null-ls")

        local python = require("plugins.lsp.python")
        local blackd = python.blackd()

        local config = vim.env.XDG_CONFIG_HOME

        null_ls.setup({
            debug = false,
            on_attach = common.on_attach,
            -- Let the LSP client set the root directory.
            root_dir = require("null-ls.utils").root_pattern(),
            should_attach = function(bufnr)
                local filename = vim.api.nvim_buf_get_name(bufnr)

                -- Ignore 3rd party code.
                if filename:match("/(node_modules|__pypackages__|site_packages)/") then
                    return false
                end

                return not vim.g.large_file
            end,
            sources = {
                null_ls.builtins.code_actions.gitrebase,
                null_ls.builtins.diagnostics.actionlint.with({
                    -- Restrict actionlint to GHA workflow files only.
                    condition = function(_)
                        return vim.api.nvim_buf_get_name(0):match("github/workflows/") ~= nil
                    end,
                }),
                null_ls.builtins.diagnostics.commitlint.with({
                    -- Restrict commitlint to non-work repos.
                    condition = function(_)
                        local cwd = vim.uv.cwd() or vim.fn.getcwd()
                        local home = vim.g.home

                        if cwd == home then
                            return true
                        end

                        return cwd:match(home .. "/dev/home") or cwd:match(home .. "/dev/src")
                    end,
                    extra_args = { string.format("--config=%s/commitlint.yaml", config) },
                }),
                null_ls.builtins.diagnostics.curlylint,
                null_ls.builtins.diagnostics.fish,
                null_ls.builtins.diagnostics.gitlint.with({
                    extra_args = { string.format("--config=%s/gitlint.ini", config) },
                }),
                null_ls.builtins.diagnostics.markdownlint.with({
                    extra_args = { string.format("--config=%s/markdownlint/config.yaml", config) },
                }),
                null_ls.builtins.diagnostics.rstcheck,
                null_ls.builtins.diagnostics.typos,
                null_ls.builtins.diagnostics.yamllint.with({
                    extra_args = { string.format("--config-file=%s/yamllint.yaml", config) },
                }),
                null_ls.builtins.formatting.beautysh,
                blackd.with({
                    extra_args = python.black_args(),
                }),
                null_ls.builtins.formatting.fish_indent,
                null_ls.builtins.formatting.gofumpt,
                null_ls.builtins.formatting.goimports,
                null_ls.builtins.formatting.golines,
                null_ls.builtins.formatting.just,
                null_ls.builtins.formatting.prettierd.with({
                    filetypes = {
                        "css",
                        "graphql",
                        "html",
                        "markdown",
                    },
                }),
                null_ls.builtins.formatting.shfmt.with({
                    extra_args = { "-i", "4", "-ci", "-s" },
                }),
                null_ls.builtins.formatting.shellharden,
                null_ls.builtins.formatting.stylua,
            },
            update_in_insert = false,
        })
    end,
    event = "VeryLazy",
}
