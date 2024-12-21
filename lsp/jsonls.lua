return {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = {
        "caddyfile",
        "json",
        "json5",
        "jsonc",
    },
    init_options = {
        provideFormatter = true,
    },
    on_attach = function(client)
        vim.api.nvim_create_user_command("JsonSchemaInfo", function()
            --
            ---@diagnostic disable-next-line: undefined-field
            for _, schema in ipairs(client.config.settings.json.schemas) do
                vim.notify(string.format("Schema: %s", schema.url))
            end
        end, {})
    end,
    on_new_config = function(c)
        c.settings = vim.tbl_deep_extend("force", c.settings, {
            json = {
                schemas = require("schemastore").json.schemas({
                    extra = {
                        {
                            description = "Caddy Web Server",
                            fileMatch = { "Caddyfile" },
                            name = "Caddyfile",
                            url = "file://" .. vim.env.XDG_CONFIG_HOME .. "/caddy/schema.json",
                        },
                    },
                }),
            },
        })
    end,
    settings = {
        validate = {
            enable = true,
        },
    },
    single_file_support = true,
}
