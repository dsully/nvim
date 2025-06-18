---@type LazySpec
return {
    ---@module "conform"
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    keys = {
        {
            "<space>f",
            function()
                require("conform").format({ async = true, lsp_format = "fallback", timeout_ms = 3000 } --[[@as conform.FormatOpts?]])
            end,
            desc = "Format Buffer",
        },
    },
    opts = function()
        ---@type conform.setupOpts
        return {
            ---@param bufnr integer
            ---@return conform.FormatOpts?
            format_on_save = function(bufnr)
                --
                if not vim.tbl_contains(defaults.formatting.on_save, vim.bo[bufnr].filetype) then
                    return nil
                end

                if vim.bo[bufnr].modifiable == false then
                    return nil
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
                    return nil
                end

                return { timeout_ms = 500, lsp_format = "fallback" } --[[@as conform.FormatOpts?]]
            end,
            formatters = {
                caddy = {
                    command = "caddy",
                    args = { "fmt" },
                    stdin = true,
                },
                injected = {
                    options = {
                        ignore_errors = true,
                    },
                },
                ["markdownlint-cli2"] = {
                    ---@param ctx conform.Context
                    condition = function(_, ctx)
                        local diag = vim.tbl_filter(function(d)
                            return d.source == "markdownlint"
                        end, vim.diagnostic.get(ctx.buf))

                        return #diag > 0
                    end,
                    prepend_args = { "--config=" .. nvim.file.xdg_config("/markdownlint/config.yaml") },
                },
                shfmt = {
                    prepend_args = { "-i", "4", "-ci", "-sr", "-s", "-bn" },
                },
                xmlformatter = {
                    prepend_args = { "--blanks", "--indent", "4" },
                },
            },
            formatters_by_ft = defaults.formatting.file_types,
        }
    end,
}
