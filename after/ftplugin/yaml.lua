vim.api.nvim_create_user_command("YAMLSchema", function()
    local schema = require("yaml-companion").get_buf_schema(vim.api.nvim_get_current_buf())

    if schema.result[1].name ~= "none" then
        vim.notify(schema.result[1].name)
    end
end, { desc = "Show YAML schema" })

-- vs = View Schema
vim.keymap.set("n", "<leader>vs", vim.cmd.YAMLSchema, { buffer = true, desc = "Show YAML schema" })

vim.keymap.set("n", "<leader>fy", function()
    require("telescope").extensions.yaml_schema.yaml_schema()
end, { buffer = true, desc = "YAML Schemas" })
