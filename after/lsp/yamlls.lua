---@type vim.lsp.ClientConfig
return {
    override = function(config)
        return require("schema-companion").setup_client(
            require("schema-companion").adapters.yamlls.setup({
                sources = {
                    require("schema-companion").sources.matchers.kubernetes.setup({ version = "master" }),
                    require("schema-companion").sources.lsp.setup(),
                    require("schema-companion").sources.schemas.setup({
                        {
                            name = "Kubernetes master",
                            uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json",
                        },
                        {
                            name = "Kubernetes v1.27",
                            uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.27.16-standalone-strict/all.json",
                        },
                        {
                            name = "Kubernetes v1.28",
                            uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.28.12-standalone-strict/all.json",
                        },
                        {
                            name = "Kubernetes v1.29",
                            uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.29.7-standalone-strict/all.json",
                        },
                        {
                            name = "Kubernetes v1.30",
                            uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.30.3-standalone-strict/all.json",
                        },
                    }),
                },
            }),
            config
        )
    end,
    --- @param client vim.lsp.Client
    --- @param bufnr integer
    -- on_attach = function(client, bufnr)
    --     local context = require("schema-companion.context")
    --
    --     context.setup(bufnr, client)
    --
    --     keys.bmap("<leader>vs", function()
    --         local schema = context.get_buffer_schema(bufnr)
    --
    --         if schema.name then
    --             Snacks.notify.info(schema.name)
    --         end
    --     end, "Show YAML schema", bufnr)
    -- end,
    --- @param client vim.lsp.Client
    on_init = function(client)
        --- Since formatting is disabled by default if you check `client:supports_method('textDocument/formatting')`
        --- during `LspAttach` it will return `false`. This hack sets the capability to `true` to facilitate
        --- autocmd's which check this capability
        if client.server_capabilities then
            client.server_capabilities.documentFormattingProvider = true
        end

        local schemas = nvim.file.read(nvim.file.xdg_config("schemas.json")) or "{}"

        ---@diagnostic disable-next-line: inject-field, need-check-nil
        client.config.settings.yaml.schemas = require("schemastore").yaml.schemas({
            extra = vim.json.decode(schemas),
        })

        client:notify(vim.lsp.protocol.Methods.workspace_didChangeConfiguration, { settings = client.config.settings })

        client:notify("yaml/supportSchemaSelection" --[[@as vim.lsp.protocol.Method.ClientToServer.Notification]], { {} })
    end,
    filetypes = {
        "yaml",
        "yaml.github",
        "!yaml.ansible",
        "!yaml.compose",
    },
    settings = {
        flags = {
            debounce_text_changes = 50,
        },
        redhat = { telemetry = { enabled = false } },
        yaml = {
            completion = true,
            editor = {
                formatOnType = false,
            },
            format = {
                enable = true,
                singleQuote = false,
            },
            hover = true,
            -- schemaStore = {
            --     enable = false,
            --     url = "",
            -- },
            schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
            schemaDownload = { enable = true },
            schemas = vim.tbl_extend("force", require("schemastore").yaml.schemas(), {
                -- kubernetes = {
                --   "templates/*!(.gitlab-ci).{yml,yaml}",
                --   "workloads/**/*!(kustomization).{yml,yaml}",
                --   "*.k8s.{yml,yaml}",
                --   "daemon.{yml,yaml}",
                --   "manager.{yml,yaml}",
                --   "restapi.{yml,yaml}",
                --   "*namespace*.{yml,yaml}",
                --   "role.{yml,yaml}",
                --   "role-binding.{yml,yaml}",
                --   "*onfigma*.{yml,yaml}",
                --   "*ingress*.{yml,yaml}",
                --   "*secret*.{yml,yaml}",
                --   "*deployment*.{yml,yaml}",
                --   "*service*.{yml,yaml}",
                --   "kubectl-edit*.yaml",
                -- },
                ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = { "*argocd*.{yml,yaml}" },
                ["http://json.schemastore.org/chart"] = { "Chart.{yml,yaml}" },
                ["https://taskfile.dev/schema.json"] = {
                    "Taskfile*.{yml,yaml}",
                },
                ["https://json.schemastore.org/pulumi.json"] = {
                    "Pulumi.{yml,yaml}",
                },
            }),
            validate = true,
        },
    },
}
