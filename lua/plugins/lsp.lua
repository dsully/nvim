return {
    "lsp",
    event = ev.LazyFile,
    config = function()
        local methods = vim.lsp.protocol.Methods

        local lsp = require("helpers.lsp")

        vim.uv.fs_unlink(vim.lsp.get_log_path())
        vim.lsp.log.set_level(vim.lsp.log.levels.ERROR)
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
        })

        -- Set defaults
        vim.lsp.config("*", {
            capabilities = require("blink.cmp").get_lsp_capabilities({
                textDocument = {
                    completion = {
                        completionItem = {
                            snippetSupport = false,
                        },
                    },
                },
            }, true),
            root_markers = { ".git" },
        })

        vim.lsp.enable(defaults.lsp.servers)

        ev.on_load("which-key.nvim", function()
            vim.schedule(function()
            -- stylua: ignore
            require("which-key").add({
                { "<C-S>", vim.lsp.buf.signature_help, desc = "Signature Help", mode = "i", icon = "󰠗 " },
                { "<leader>l", group = "LSP", icon = " " },
                { "<leader>lc", vim.cmd.LspCapabilities, desc = "LSP Capabilities", icon = " " },
                -- { "<leader>li", vim.cmd.LspInfo, desc = "LSP Info", icon = " " },
                { "<leader>ll", vim.cmd.LspLog, desc = "LSP Log", icon = " " },
                { "<leader>lr", vim.cmd.LspRestartBuffer, desc = "LSP Restart", icon = " " },
                { "<leader>ls", vim.cmd.LspStop, desc = "LSP Stop", icon = " " },
                { "<leader>xr", vim.diagnostic.reset, desc = "Reset", icon = " " },
                { "<leader>xs", vim.diagnostic.open_float, desc = "Show", icon = "󰙨" },
                { "gra", require("helpers.lsp").code_action, desc = "Actions", icon = "󰅯 " },
                { "grf", function() require("snacks").rename.rename_file() end, desc = "Rename File", icon = " ", },
                { "grn", vim.lsp.buf.rename, desc = "Rename", icon = " " },
                { "grq", require("helpers.lsp").apply_quickfix, desc = "Apply Quick Fix", icon = "󱖑 " },
            }, { notify = false })
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

        lsp.on_attach(lsp.validate_client)
        lsp.on_dynamic_capability(lsp.validate_client)
        lsp.on_dynamic_capability(function() end)
        lsp.commands()

        lsp.on_supports_method(methods.textDocument_inlayHint, function()
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

        ---@param client vim.lsp.Client
        ---@param buffer number
        lsp.on_supports_method(methods.textDocument_documentHighlight, function(client, buffer)
            --
            local debounce = require("helpers.debounce").debounce

            local group = string.format("%s/highlight/%s", client.name, buffer)
            local id = ev.group(group)

            ev.on(
                { ev.BufEnter, ev.CursorMoved, ev.FocusGained, ev.WinEnter },
                debounce(200, function()
                    vim.lsp.buf.clear_references()

                    local enc = client.offset_encoding
                    local win = vim.api.nvim_get_current_win()

                    client:request(methods.textDocument_documentHighlight, vim.lsp.util.make_position_params(0, enc), function(_, result, ctx)
                        if not result or win ~= vim.api.nvim_get_current_win() then
                            return
                        end

                        vim.lsp.util.buf_highlight_references(ctx.bufnr, result, enc)
                    end, buffer)
                end),
                {
                    group = id,
                    buffer = buffer,
                    desc = group .. "/highlight",
                }
            )

            ev.on({ ev.BufLeave, ev.FocusLost, ev.WinLeave }, function()
                if vim.api.nvim_buf_is_valid(buffer) then
                    vim.lsp.buf.clear_references()
                end
            end, {
                group = id,
                buffer = buffer,
                desc = group .. "/clear",
            })
        end)
    end,
    virtual = true,
}
