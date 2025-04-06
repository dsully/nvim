---@type LazySpec
return {
    "lsp",
    event = ev.LazyFile,
    config = function()
        local methods = vim.lsp.protocol.Methods

        vim.uv.fs_unlink(vim.lsp.get_log_path())
        vim.lsp.log.set_level(vim.lsp.log.levels.WARN)
        vim.lsp.log.set_format_func(vim.inspect)

        vim.diagnostic.config({
            float = {
                border = defaults.ui.border.name,
                focusable = true,
                header = { "" },
                severity_sort = true,
                spacing = 2,
                source = true,
            },
            severity_sort = true,
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = defaults.icons.diagnostics.error,
                    [vim.diagnostic.severity.WARN] = defaults.icons.diagnostics.warn,
                    [vim.diagnostic.severity.INFO] = defaults.icons.diagnostics.info,
                    [vim.diagnostic.severity.HINT] = defaults.icons.diagnostics.hint,
                },
            },
            underline = true,
            update_in_insert = false, -- https://www.reddit.com/r/neovim/comments/pfk209/nvimlsp_too_fast/
        } --[[@as vim.diagnostic.Opts]])

        -- Set defaults
        vim.lsp.config("*", {
            root_markers = { ".git" },
        } --[[@as vim.lsp.Config]])

        vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
            :map(function(config_path)
                return vim.fs.basename(config_path):match("^(.*)%.lua$")
            end)
            :each(function(server_name)
                vim.lsp.enable(server_name, nvim.lsp.should_enable(server_name))
            end)

        ev.on_load("which-key.nvim", function()
            vim.schedule(function()
            -- stylua: ignore
            require("which-key").add({
                { "<C-S>", vim.lsp.buf.signature_help, desc = "Signature Help", mode = "i", icon = "󰠗 " },
                { "<leader>l", group = "LSP", icon = " " },
                { "<leader>lc", vim.cmd.LspCapabilities, desc = "LSP Capabilities", icon = " " },
                { "<leader>li", nvim.lsp.info, desc = "LSP Info", icon = " " },
                { "<leader>ll", vim.cmd.LspLog, desc = "LSP Log", icon = " " },
                { "<leader>lr", vim.cmd.LspRestartBuffer, desc = "LSP Restart", icon = " " },
                { "<leader>ls", vim.cmd.LspStop, desc = "LSP Stop", icon = " " },
                { "<leader>xr", vim.diagnostic.reset, desc = "Reset", icon = " " },
                { "<leader>xs", vim.diagnostic.open_float, desc = "Show", icon = "󰙨" },
                { "gra", nvim.lsp.code_action, desc = "Actions", icon = "󰅯 " },
                { "grn", vim.lsp.buf.rename, desc = "Rename", icon = " " },
                { "grq", nvim.lsp.apply_quickfix, desc = "Apply Quick Fix", icon = "󱖑 " },

                -- Snacks pickers
                { "gD", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition" },
                { "gO", function() Snacks.picker.lsp_symbols() end, desc = "References" },
                { "gd", function() Snacks.picker.lsp_definitions({ unique_lines = true }) end, desc = "Goto Definition" },
                { "gi", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
                { "grf", function() Snacks.rename.rename_file() end, desc = "Rename File", icon = " ", },
                { "grr", function() Snacks.picker.lsp_references({ nowait = true }) end, desc = "References" },
            } --[[@as wk.Spec]], { notify = false })
            end)
        end)

        -- Handle dynamic registration.
        --
        -- https://github.com/neovim/neovim/issues/24229
        local register_capability = vim.lsp.handlers[methods.client_registerCapability]

        ---@param res lsp.RegistrationParams
        ---@param ctx lsp.HandlerContext
        vim.lsp.handlers[methods.client_registerCapability] = function(err, res, ctx)
            local client_id = ctx.client_id
            local client = vim.lsp.get_client_by_id(client_id)

            if client then
                for buffer in pairs(client.attached_buffers) do
                    --
                    ev.emit(ev.User, {
                        pattern = ev.LspDynamicCapability,
                        data = { client_id = client.id, buffer = buffer },
                    })
                end
            end

            return register_capability(err, res, ctx)
        end

        nvim.lsp.on_attach(nvim.lsp.validate_client)
        nvim.lsp.on_dynamic_capability(nvim.lsp.validate_client)
        nvim.lsp.on_dynamic_capability(function() end)
        nvim.lsp.commands()

        nvim.lsp.on_supports_method(methods.textDocument_inlayHint, function()
            vim.lsp.inlay_hint.enable(false)
        end)

        -- Disable codeLens for now.
        -- lsp.on_supports_method(methods.textDocument_codeLens, function(_, buffer)
        --     vim.lsp.codelens.refresh()
        --
        --     ev.on({ ev.BufEnter, ev.CursorHold, ev.InsertLeave }, vim.lsp.codelens.refresh, {
        --         buffer = buffer,
        --     })
        -- end)
    end,
    virtual = true,
}
