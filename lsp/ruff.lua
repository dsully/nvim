---@type vim.lsp.Config
return {
    cmd = { "ruff", "server" },
    commands = {
        RuffApplyAutofix = function()
            require("helpers.ruff").command("ruff.applyAutofix")
        end,
        RuffOrganizeImports = function()
            require("helpers.ruff").command("ruff.organizeImports")
        end,
        RuffDebug = function()
            local current_lsp_log_level = vim.lsp.log.get_level()

            vim.lsp.set_log_level(vim.log.levels.INFO)

            require("helpers.ruff").command("ruff.printDebugInformation", function()
                vim.cmd.tabedit(vim.fs.joinpath(tostring(vim.fn.stdpath("log")), "lsp.ruff.log"))

                vim.keymap.set("n", "q", "<Cmd>quit<CR>", { buffer = true })
                vim.lsp.set_log_level(current_lsp_log_level)
            end)
        end,
    },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml" },
    single_file_support = true,
}
