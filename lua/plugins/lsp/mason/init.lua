--
for _, i in pairs({
    "starlark_rust",
}) do
    require("mason-lspconfig.mappings.server").lspconfig_to_package[i] = i
    require("mason-lspconfig.mappings.server").package_to_lspconfig[i] = i
end

return {
    starlark_rust = "plugins.lsp.mason.starlark_rust",
}
