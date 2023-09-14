--
for _, i in pairs({ "dmypyls", "pylance" }) do
    require("mason-lspconfig.mappings.server").lspconfig_to_package[i] = i
    require("mason-lspconfig.mappings.server").package_to_lspconfig[i] = i
end

return {
    dmypyls = "plugins.lsp.mason.dmypyls",
    pylance = "plugins.lsp.mason.pylance",
}
