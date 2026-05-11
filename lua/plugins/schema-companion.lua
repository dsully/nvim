---@type LazySpec[]
return {
    {
        "cenk1cenk2/schema-companion.nvim",
        ft = {
            "helm",
            "json",
            "jsonc",
            "toml",
            "yaml",
            "yaml.*",
        },
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
                    require("schema-companion").select_schema()
                end,
                desc = "Select a Schema",
            },
        },
        opts = {
            log_level = vim.log.levels.ERROR,
        },
    },
}
