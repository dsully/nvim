-- Jump directly to the first available definition every time.
-- Use Telescope if there is more than one result.
vim.lsp.handlers["textDocument/definition"] = function(_, result, ctx)
    if not result or vim.tbl_isempty(result) then
        vim.api.nvim_echo({ { "LSP: Could not find definition" } }, false, {})
        return
    end

    local client = vim.lsp.get_client_by_id(ctx.client_id)

    if not client then
        return
    end

    if vim.tbl_islist(result) then
        local results = vim.lsp.util.locations_to_items(result, client.offset_encoding)
        local lnum, filename = results[1].lnum, results[1].filename

        for _, val in pairs(results) do
            if val.lnum ~= lnum or val.filename ~= filename then
                return require("telescope.builtin").lsp_definitions()
            end
        end

        vim.lsp.util.jump_to_location(result[1], client.offset_encoding, false)
    else
        vim.lsp.util.jump_to_location(result, client.offset_encoding, true)
    end
end

--
-- See: https://github.com/neovim/neovim/issues/19649
local original = vim.lsp.handlers["textDocument/publishDiagnostics"]

vim.lsp.handlers["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
    vim.tbl_map(function(item)
        if item.relatedInformation and #item.relatedInformation > 0 then
            vim.tbl_map(function(k)
                if k.location then
                    --
                    k.message = vim.fn.fnamemodify(vim.uri_to_fname(k.location.uri), ":t")
                        .. "("
                        .. (k.location.range.start.line + 1)
                        .. ", "
                        .. (k.location.range.start.character + 1)
                        .. "): "
                        .. k.message

                    if k.location.uri == vim.uri_from_bufnr(0) then
                        table.insert(result.diagnostics, {
                            code = item.code,
                            message = k.message,
                            range = k.location.range,
                            severity = vim.lsp.protocol.DiagnosticSeverity.Hint,
                            source = item.source,
                            relatedInformation = {},
                        })
                    end
                end
                item.message = item.message .. "\n" .. k.message
            end, item.relatedInformation)
        end
    end, result.diagnostics)

    original(_, result, ctx, config)
end

local float_group = vim.api.nvim_create_namespace("LSP Float")

--- From: https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lua/lsp.lua#L212
---
--- LSP handler that adds extra inline highlights, keymaps, and window options.
--- Code inspired from `noice`.
--
---@param handler fun(err: any, result: any, ctx: any, config: any): integer, integer
---@return function
local enhanced_float_handler = function(handler)
    ---@param ctx lsp.HandlerContext
    return function(err, result, ctx, config)
        local buf, win = handler(
            err,
            result,
            ctx,
            vim.tbl_deep_extend("force", config or {}, {
                border = vim.g.border,
                title = "  ",
                max_height = math.floor(vim.o.lines * 0.5),
                max_width = math.floor(vim.o.columns * 1.0),
            })
        )

        if not buf or not win then
            return
        end

        -- Conceal everything.
        vim.wo[win].concealcursor = "n"

        -- Extra highlights.
        for l, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
            for pattern, hl_group in pairs({
                ["|%S-|"] = "@text.reference",
                ["@%S+"] = "@parameter",
                ["^%s*(Parameters:)"] = "@text.title",
                ["^%s*(Return:)"] = "@text.title",
                ["^%s*(See also:)"] = "@text.title",
                ["{%S-}"] = "@parameter",
                ["^%s*(%{%{%{)"] = "Conceal", -- For vim folds showing up in documentation
                ["^%s*(%}%}%})"] = "Conceal",
            }) do
                local conceal = nil
                local from = 1 ---@type integer?
                while from do
                    local to
                    from, to = line:find(pattern, from)
                    if hl_group == "Conceal" then
                        conceal = ""
                    end
                    if from then
                        vim.api.nvim_buf_set_extmark(buf, float_group, l - 1, from - 1, {
                            end_col = to,
                            hl_group = hl_group,
                            conceal = conceal,
                        })
                    end
                    from = to and to + 1 or nil
                end
            end
        end

        -- Add key maps for opening links.
        if not vim.b[buf].markdown_keys then
            vim.keymap.set("n", "K", function()
                -- Vim help links.
                local url = (vim.fn.expand("<cWORD>") --[[@as string]]):match("|(%S-)|")

                if url then
                    return vim.cmd.help(url)
                end

                -- Markdown links.
                local col = vim.api.nvim_win_get_cursor(0)[2] + 1
                local from, to

                from, to, url = vim.api.nvim_get_current_line():find("%[.-%]%((%S-)%)")

                if from and col >= from and col <= to then
                    vim.system({ "open", url }, nil, function(res)
                        if res.code ~= 0 then
                            vim.notify("Failed to open URL" .. url, vim.log.levels.ERROR)
                        end
                    end)
                end
            end, { buffer = buf, silent = true })

            vim.b[buf].markdown_keys = true
        end
    end
end

vim.lsp.handlers[vim.lsp.protocol.Methods.textDocument_hover] = enhanced_float_handler(vim.lsp.handlers.hover)
vim.lsp.handlers[vim.lsp.protocol.Methods.textDocument_signatureHelp] = enhanced_float_handler(vim.lsp.handlers.signature_help)
