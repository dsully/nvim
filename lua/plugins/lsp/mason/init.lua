--
for _, i in pairs({
    "bzl",
}) do
    require("mason-lspconfig.mappings.server").lspconfig_to_package[i] = i
    require("mason-lspconfig.mappings.server").package_to_lspconfig[i] = i
end

return {
    bzl = "plugins.lsp.mason.bzl",
}
