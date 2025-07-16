---@type LazySpec[]
return {
    {
        "cenk1cenk2/schema-companion.nvim",
        ft = { "helm", "yaml" },
        keys = {
            {
                "<leader>ys",
                function()
                    local schemas = require("schema-companion.schema").all()

                    if not schemas or #schemas == 0 then
                        vim.notify("No schemas available", vim.log.levels.WARN, { title = "Schema Companion" })
                        return
                    end

                    vim.ui.select(schemas, {
                        prompt = "Select any available schema",
                        format_item = function(item)
                            return item.name or item.uri or "<unnamed>"
                        end,
                    }, function(choice)
                        if choice then
                            require("schema-companion.context").schema(vim.api.nvim_get_current_buf(), {
                                name = choice.name or choice.uri,
                                uri = choice.uri,
                            })
                        end
                    end)
                end,
                desc = "Select a YAML Schema",
            },
        },
        opts = {},
    },
}
