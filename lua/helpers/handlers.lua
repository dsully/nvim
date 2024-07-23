local M = {}

local methods = vim.lsp.protocol.Methods

---@param title string
---@param opts table
local function location_handler(title, opts)
    --
    --- Jumps to a location. Used as a handler for multiple LSP methods.
    ---@param result table result of LSP method; a location or a list of locations.
    ---@param ctx lsp.HandlerContext table containing the context of the request, including the method
    return function(_, result, ctx)
        --
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        local results = {}

        if vim.islist(result) then
            results = result
        else
            results = { result }
        end

        if not result or not results or vim.tbl_isempty(results) or not client then
            vim.api.nvim_echo({ { "LSP: No locations found." } }, false, {})
            return
        end

        if vim.islist(results) then
            local conf = require("telescope.config").values

            local items = vim.lsp.util.locations_to_items(results, client.offset_encoding)
            local lnum, filename = items[1].lnum, items[1].filename
            local picked = false

            for _, val in pairs(items) do
                if val.lnum ~= lnum or val.filename ~= filename then
                    picked = true
                end
            end

            if picked then
                require("telescope.pickers")
                    .new(opts, {
                        prompt_title = title,
                        finder = require("telescope.finders").new_table({
                            results = items,
                            entry_maker = opts.entry_maker or require("telescope.make_entry").gen_from_quickfix(),
                        }),
                        previewer = conf.qflist_previewer(opts),
                        sorter = conf.generic_sorter(opts),
                        push_cursor_on_edit = true,
                        push_tagstack_on_edit = true,
                    })
                    :find()
            else
                vim.lsp.util.jump_to_location(results[1], client.offset_encoding, false)
            end
        else
            vim.lsp.util.jump_to_location(results[1], client.offset_encoding, true)
        end
    end
end

-- Adapted from https://gist.github.com/MunifTanjim/8d9498c096719bdf4234321230fe3dc7
M.rename = function()
    local Input = require("nui.input")
    local event = require("nui.utils.autocmd").event

    local current_name = vim.fn.expand("<cword>")

    local params = vim.lsp.util.make_position_params()

    local function on_submit(new_name)
        --
        if not new_name or #new_name == 0 then
            vim.api.nvim_notify("Cancelled: New name is empty!", vim.log.levels.INFO, {
                icon = "",
                title = "LSP",
            })
            return
        elseif new_name == current_name then
            vim.api.nvim_notify("Cancelled: New and current names are the same!", vim.log.levels.INFO, {
                icon = "",
                title = "LSP",
            })
            return
        end

        local relative_path = function(file_path)
            local plenary_path = require("plenary.path")
            local parsed_path, _ = file_path:gsub("file://", "")
            local path = plenary_path:new(parsed_path)
            local relative_path = path:make_relative(vim.uv.cwd())
            return "./" .. relative_path
        end

        params.newName = new_name ---@diagnostic disable-line: inject-field

        vim.lsp.buf_request(0, vim.lsp.protocol.Methods.textDocument_rename, params, function(err, result, ctx, _)
            --
            if err or not result then
                vim.notify(("Error running LSP query '%s': %s"):format(ctx.method, err), vim.log.levels.ERROR)
                return
            end

            -- The `result` contains all the places we need to update the name of the identifier. so we apply those edits.
            vim.lsp.util.apply_workspace_edit(result, vim.lsp.get_client_by_id(ctx.client_id).offset_encoding)

            -- Display notification with the changed files
            -- https://github.com/mattleong/CosmicNvim/blob/85fea07d98a340813898c35ea8266efdd826fe88/lua/cosmic/core/theme/ui.lua
            if result.documentChanges then
                local msg = {}

                for _, changes in pairs(result.documentChanges) do
                    table.insert(msg, ("%d changes: %s"):format(#changes.edits, relative_path(changes.textDocument.uri)))
                end

                vim.api.nvim_notify("Renamed " .. current_name .. " into " .. new_name .. ".", vim.log.levels.INFO, {
                    icon = "",
                    title = "LSP",
                })

                -- After the edits are applied, the files are not saved automatically.
                local total_files = vim.tbl_count(result.documentChanges)

                print(string.format("Changed %s file%s. To save them run ':wa'", total_files, total_files > 1 and "s" or ""))
            end
        end)
    end

    local popup_options = {
        border = {
            style = vim.g.border,
            text = {
                top = "[Rename]",
                top_align = "left",
            },
        },
        highlight = "Normal:Normal,FloatBorder:DiagnosticInfo",
        -- Place the pop-up window relative to the buffer position of the identifier.
        relative = {
            type = "cursor",
            position = {
                row = params.position.line,
                col = params.position.character,
            },
        },
        -- Position the pop-up window on the line below identifier
        position = {
            row = -2,
            col = -2,
        },
        size = {
            width = math.max(#current_name + 20, 35),
            height = 2,
        },
    }

    local input = Input(popup_options, {
        default_value = current_name,
        on_submit = on_submit,
        prompt = " ",
    })

    input:mount()

    -- Make it easier to move around long words
    local kw = vim.opt.iskeyword - "_" - "-"
    vim.bo.iskeyword = table.concat(kw:get(), ",")

    -- Close on <esc> in normal mode
    input:map("n", "<esc>", input.input_props.on_close, { noremap = true })
    input:map("n", "<C-c>", input.input_props.on_close, { noremap = true })

    -- Ctrl-W to delete word.
    input:map("i", "<C-w>", "<C-o>diw", { noremap = true, silent = true })

    -- Close when cursor leaves the buffer
    input:on(event.BufLeave, input.input_props.on_close, { once = true })
end

---@param group integer
M.setup = function(group)
    local opts = {}

    for req, handler in pairs({
        [methods.textDocument_declaration] = location_handler("LSP Declarations", opts),
        [methods.textDocument_definition] = location_handler("LSP: Definitions", {
            fname_width = 40,
            include_current_line = false,
            trim_text = true,
        }),
        [methods.textDocument_implementation] = location_handler("LSP: Implementations", opts),
        [methods.textDocument_typeDefinition] = location_handler("LSP Type Definitions", opts),
        [methods.textDocument_references] = location_handler("LSP: References", {
            include_current_line = false,
        }),
    }) do
        vim.lsp.handlers[req] = handler
    end

    -- De-duplicate diagnostics, in particular from rust-analyzer/rustc
    ---@param result lsp.PublishDiagnosticsParams
    vim.lsp.handlers[methods.textDocument_publishDiagnostics] = vim.lsp.with(function(_, result, ...)
        --
        ---@type table<string, lsp.Diagnostic>>
        local seen = {}

        ---@param diagnostic lsp.Diagnostic
        for _, diagnostic in ipairs(result.diagnostics) do
            local key = string.format("%s:%s", diagnostic.code, diagnostic.range.start.line)

            seen[key] = diagnostic
        end

        result.diagnostics = vim.tbl_values(seen)

        vim.lsp.diagnostic.on_publish_diagnostics(_, result, ...)
    end, {})

    -- Handle dynamic registration.
    --
    -- https://github.com/neovim/neovim/issues/24229
    local register_capability = vim.lsp.handlers[methods.client_registerCapability]

    ---@param res lsp.RegistrationParams
    ---@param ctx lsp.HandlerContext
    vim.lsp.handlers[methods.client_registerCapability] = function(err, res, ctx)
        local client_id = ctx.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        local buffer = vim.api.nvim_get_current_buf()

        if client then
            require("plugins.lsp.common").on_attach(client, buffer, group)
        end

        return register_capability(err, res, ctx)
    end
end

return M
