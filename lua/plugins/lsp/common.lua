local M = {}

-- Hook up autocomplete for LSP to nvim-cmp, see: https://github.com/hrsh7th/cmp-nvim-lsp
M.capabilities = function()
    --
    -- Since cmp-nvim-lsp has an after/ file which load cmp, which I want deferred until InsertEnter,
    -- create a cache of the table that .default_capabilities() emits to JSON to be loaded instead.
    local path = vim.fn.stdpath("cache") .. "/capabilities.json"
    local module = "cmp_nvim_lsp"

    if not vim.uv.fs_stat(path) then
        require("lazy").load({ plugins = { "cmp-nvim-lsp" } })

        vim.fn.writefile({ vim.json.encode(require(module).default_capabilities()) }, path)

        require("plenary.reload").reload_module(module)
    end

    return vim.json.decode(vim.fn.readfile(path)[1])
end

M.groups = {
    code_lens = vim.api.nvim_create_augroup("LSP Code Lens", { clear = false }),
    inlay_hints = vim.api.nvim_create_augroup("LSP Inlay Hints Refresh", { clear = false }),
    lsp_highlight = vim.api.nvim_create_augroup("LSP Highlight References", { clear = false }),
}

M.on_attach = function(client, buffer)
    local methods = vim.lsp.protocol.Methods

    --
    -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#highlight-symbol-under-cursor

    if client.supports_method(methods.textDocument_documentHighlight) then
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = M.groups.lsp_highlight,
            buffer = buffer,
            callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ "CursorMoved" }, {
            group = M.groups.lsp_highlight,
            callback = vim.lsp.buf.clear_references,
        })
    end

    -- General diagnostics.
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "󰙨󰙨 Next Diagnostic" })
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "󰙨󰙨 Previous Diagnostic" })
    vim.keymap.set("n", "<leader>xr", vim.diagnostic.reset, { desc = " Reset" })
    vim.keymap.set("n", "<leader>xs", vim.diagnostic.open_float, { desc = "󰙨 Show" })

    if client.supports_method(methods.textDocument_signatureHelp) then
        vim.keymap.set("n", "<leader>ch", vim.lsp.buf.signature_help, { desc = "󰞂 Signature Help" })
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { desc = "󰞂 Signature Help" })
    end

    if client.supports_method(methods.textDocument_declaration) then
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "󰁴 Go To Declaration" })
    end

    if client.supports_method(methods.textDocument_inlayHint) then
        vim.keymap.set("n", "<space>i", function()
            vim.lsp.inlay_hint(buffer)
        end, { desc = " Toggle Inlay Hints" })

        vim.lsp.inlay_hint(buffer, false)
    end

    if client.supports_method(methods.textDocument_codeAction) then
        vim.keymap.set({ "n", "x" }, "<leader>ca", require("actions-preview").code_actions, { desc = "󰅯 Actions" })
    end

    -- https://github.com/smjonas/inc-rename.nvim
    if client.supports_method(methods.textDocument_rename) then
        vim.keymap.set("n", "<leader>cr", function()
            --
            return ":" .. require("inc_rename").config.cmd_name .. " " .. vim.fn.expand("<cword>")
        end, { desc = "  Rename", expr = true })
    end

    if client.supports_method(methods.textDocument_codeLens) then
        --
        vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost" }, {
            desc = "LSP Code Lens Refresh",
            -- call via Vimscript so that errors are silenced
            command = "silent! lua vim.lsp.codelens.refresh()",
            buffer = buffer,
            group = M.groups.code_lens,
        })
    end

    -- Telescope based finders.
    if client.supports_method(methods.textDocument_definition) then
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "󰁴 Go To Definition(s)" })
    end

    if client.supports_method(methods.textDocument_implementation) then
        vim.keymap.set("n", "gi", function()
            vim.cmd.Telescope("lsp_implementations")
        end, { desc = "󰘲 Go To Implementations(s)" })
    end

    if client.supports_method(methods.textDocument_references) then
        vim.keymap.set("n", "<leader>fR", function()
            vim.cmd.Telescope("lsp_references")
        end, { desc = "󰆋 References" })
    end

    if client.supports_method(methods.textDocument_documentSymbol) then
        vim.keymap.set("n", "<leader>fS", function()
            vim.cmd.Telescope("lsp_document_symbols")
        end, { desc = "󰆋 Symbols" })
    end

    if client.supports_method(methods.workspace_symbol) then
        vim.keymap.set("n", "<leader>fW", function()
            vim.cmd.Telescope("lsp_dynamic_workspace_symbols")
        end, { desc = "󰆋 Workspace Symbols" })
    end

    -- Diagnostics
    vim.keymap.set("n", "<leader>xl", function()
        vim.cmd.Telescope("loclist")
    end, { desc = " Location List" })

    vim.keymap.set("n", "<leader>xq", function()
        vim.cmd.Telescope("quickfix")
    end, { desc = "󰁨 Quickfix" })
end

local float_namespace = vim.api.nvim_create_namespace("my/lsp_float")

--- From: https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lua/lsp.lua#L212
---
--- LSP handler that adds extra inline highlights, keymaps, and window options.
--- Code inspired from `noice`.
--
---@param handler fun(err: any, result: any, ctx: any, config: any): integer, integer
---@return function
M.enhanced_float_handler = function(handler)

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
                        vim.api.nvim_buf_set_extmark(buf, float_namespace, l - 1, from - 1, {
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

vim.lsp.handlers[vim.lsp.protocol.Methods.textDocument_hover] = M.enhanced_float_handler(vim.lsp.handlers.hover)
vim.lsp.handlers[vim.lsp.protocol.Methods.textDocument_signatureHelp] = M.enhanced_float_handler(vim.lsp.handlers.signature_help)

-- Adapted from folke/lazyvim
-- Searches & sets the root directory based on:
--
-- * LSP workspace folders
-- * LSP root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
M.find_root = function()
    local root_patterns = {
        ".chezmoiroot",
        ".stylua.toml",
        "configure",
        "package.json",
        "pyproject.toml",
        "requirements.txt",
        "ruff.toml",
        "selene.toml",
        "setup.cfg",
        "setup.py",
        "stylua.toml",
        "Cargo.toml",
    }

    ---@type string?
    local path = vim.api.nvim_buf_get_name(0)
    path = path ~= "" and vim.uv.fs_realpath(path) or nil

    ---@type string[]
    local roots = {}
    local cwd = vim.uv.cwd()

    if path then
        for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
            if not vim.tbl_contains({ "copilot" }, client.name) then
                local workspace = client.config.workspace_folders

                local paths = workspace and vim.tbl_map(function(ws)
                    return vim.uri_to_fname(ws.uri)
                end, workspace) or client.config.root_dir and { client.config.root_dir } or {}

                for _, p in ipairs(paths) do
                    local r = vim.uv.fs_realpath(p)

                    if r then
                        if path:find(r, 1, true) then
                            roots[#roots + 1] = r
                        end
                    end
                end
            end
        end
    end

    table.sort(roots, function(a, b)
        return #a > #b
    end)

    ---@type string?
    local root = roots[1]

    if not root then
        path = path and vim.fs.dirname(path) or cwd

        ---@type string?
        root = vim.fs.find(root_patterns, { path = path, upward = true })[1]
        root = root and vim.fs.dirname(root) or cwd
    end

    ---@cast root string
    return root
end

return M
