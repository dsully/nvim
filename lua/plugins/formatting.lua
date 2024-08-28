return {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    event = { ev.BufWritePre, ev.LspAttach },
    keys = {
        {
            "<space>f",
            function()
                require("conform").format({ async = true, lsp_format = "fallback", timeout_ms = 3000 })
            end,
            desc = "Format Buffer",
        },
    },
    opts = function()
        return {
            format_on_save = function(bufnr)
                --
                if not vim.tbl_contains(defaults.formatting.on_save, vim.bo[bufnr].filetype) then
                    return false
                end

                -- Disable autoformat for files in a certain path
                local bufname = vim.api.nvim_buf_get_name(bufnr)

                if
                    bufname:find("node_modules")
                    or bufname:find("__pypackages__")
                    or bufname:find("site_packages")
                    or bufname:find("cargo/registry")
                    or bufname:find("product-spec.json")
                    or bufname:find("Cargo.lock")
                then
                    return false
                end

                return { timeout_ms = 500, lsp_format = "fallback" }
            end,
            formatters = {
                caddy = {
                    command = "caddy",
                    args = { "fmt", "-" },
                    stdin = true,
                },
                ["markdown-toc"] = {
                    condition = function(_, ctx)
                        for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
                            if line:find("<!%-%- toc %-%->") then
                                return true
                            end
                        end
                    end,
                },
                ["markdownlint-cli2"] = {
                    condition = function(_, ctx)
                        local diag = vim.tbl_filter(function(d)
                            return d.source == "markdownlint"
                        end, vim.diagnostic.get(ctx.buf))
                        return #diag > 0
                    end,
                    prepend_args = { string.format("--config=%s/markdownlint/config.yaml", vim.env.XDG_CONFIG_HOME) },
                },
                shfmt = {
                    prepend_args = { "-i", "2", "-ci", "-sr", "-s", "-bn" },
                },
                -- Remove when https://github.com/tamasfe/taplo/issues/560 is addressed.
                taplo = {
                    args = { "format", "--config=" .. vim.env.XDG_CONFIG_HOME .. "/taplo.toml", "-" },
                },
            },
            formatters_by_ft = defaults.formatting.file_types,
        }
    end,
}
