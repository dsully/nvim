local Pkg = require("mason-core.package")
local pip3 = require("mason-core.managers.pip3")

return Pkg.new({
    name = "dmypyls",
    desc = "super fast mypy language server",
    homepage = "https://pypi.org/project/dmypy-ls/",
    languages = { Pkg.Lang.Python },
    categories = { Pkg.Cat.LSP },
    install = pip3.packages({ "dmypy-ls", bin = { "dmypy-ls" } }),
})
