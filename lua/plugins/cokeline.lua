---@type LazySpec
return {
    "willothy/nvim-cokeline",
    config = function()
        local icons = defaults.icons

        local mappings = require("cokeline.mappings")
        local map = require("helpers.keys").map

        for i = 1, 9 do
                -- stylua: ignore
                map("<leader>" .. i, function() mappings.by_index("focus", i) end, "which_key_ignore")

                -- Allow Option-N in terminals.
                -- stylua: ignore
                map(string.format("<M-%d>", i), function() mappings.by_index("focus", i) end, "which_key_ignore")
        end

        ---@type Component
        local components = {
            space = {
                text = " ",
                truncation = { priority = 1 },
            },

            separator = {
                ---@param buffer Buffer
                text = function(buffer)
                    return buffer.index == 1 and " " or " " .. icons.separators.bar.left
                end,
                bg = "TabLineFill",
                truncation = { priority = 1 },
            },

            devicon = {
                ---@param buffer Buffer
                text = function(buffer)
                    return buffer.devicon.icon
                end,
                ---@param buffer Buffer
                fg = function(buffer)
                    return buffer.devicon.color
                end,
                italic = function(_)
                    return mappings.is_picking_focus() or mappings.is_picking_close()
                end,
                bold = function(_)
                    return mappings.is_picking_focus() or mappings.is_picking_close()
                end,
                truncation = { priority = 1 },
            },

            idx = {
                ---@param buffer Buffer
                text = function(buffer)
                    return buffer.index .. ": "
                end,
                truncation = { priority = 1 },
            },

            unique_prefix = {
                ---@param buffer Buffer
                text = function(buffer)
                    return buffer.unique_prefix
                end,
                fg = "Comment",
                style = "italic",
                truncation = {
                    priority = 3,
                    direction = "left",
                },
            },

            filename = {
                ---@param buffer Buffer
                text = function(buffer)
                    return buffer.filename
                end,
                ---@param buffer Buffer
                bold = function(buffer)
                    return buffer.is_focused
                end,
                ---@param buffer Buffer
                underline = function(buffer)
                    return buffer.is_hovered and not buffer.is_focused
                end,
                ---@param buffer Buffer
                fg = function(buffer)
                    --
                    -- Don't show diagnostics for non-project buffers.
                    if not buffer.path:find(tostring(vim.uv.cwd()), 1, true) then
                        return
                    end

                    if buffer.diagnostics.errors ~= 0 then
                        return "DiagnosticError"
                    elseif buffer.diagnostics.warnings ~= 0 then
                        return "DiagnosticWarn"
                    elseif buffer.diagnostics.infos ~= 0 then
                        return "DiagnosticInfo"
                    end
                end,
                truncation = {
                    priority = 2,
                    direction = "left",
                },
            },

            close_or_unsaved = {
                ---@param buffer Buffer
                text = function(buffer)
                    if buffer.is_hovered then
                        return buffer.is_modified and icons.misc.modified or icons.actions.close_round
                    else
                        return buffer.is_modified and icons.misc.modified or icons.actions.close
                    end
                end,
                bold = true,
                delete_buffer_on_left_click = true,
                ---@param buffer Buffer
                fg = function(buffer)
                    return buffer.is_modified and "DiagnosticOk" or nil
                end,
                truncation = { priority = 1 },
            },
        }

        require("cokeline").setup({
            components = {
                components.separator,
                components.space,
                components.devicon,
                components.space,
                components.idx,
                components.unique_prefix,
                components.filename,
                components.space,
                components.close_or_unsaved,
                components.space,
            },
        })
    end,
    event = ev.UIEnter,
    keys = {
        {
            "<leader>bd",
            function()
                local current = require("cokeline.buffers").get_current()

                if current then
                    current:delete()
                end
            end,
            desc = "Delete Buffer",
        },
    },
}
