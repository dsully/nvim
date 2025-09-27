---@type LazySpec[]
return {
    {
        "cenk1cenk2/schema-companion.nvim",
        ft = { "yaml", "helm", "yaml.*", "json*", "toml" },
        keys = {
            {
                "<leader>vs",
                function()
                    Snacks.notify.info(require("schema-companion").get_current_schemas() or "none")
                end,
                desc = "Show the current Schema",
            },
            {
                "<leader>vS",
                function()
                    return require("schema-companion").select_schema()
                end,
                desc = "Select a Schema",
            },
        },
        opts = {},
    },
}
