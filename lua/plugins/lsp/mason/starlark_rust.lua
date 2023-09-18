local Pkg = require("mason-core.package")
local cargo = require("mason-core.managers.cargo")

return Pkg.new({
    name = "starlark_rust",
    desc = "Bazel language server",
    homepage = "https://crates.io/crates/starlark",
    languages = { Pkg.Lang.Starlark },
    categories = { Pkg.Cat.LSP },
    install = cargo.crate("starlark", {
        bin = { "starlark" },
    }),
})
