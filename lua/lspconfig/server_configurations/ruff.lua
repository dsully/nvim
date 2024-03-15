local root_dir = function(fname)
    local lsputil = require("lspconfig.util")

    local markers = {
        ".ruff.toml",
        "pyproject.toml",
        "ruff.toml",
        "setup.cfg",
    }

    return lsputil.root_pattern(unpack(markers))(fname) or lsputil.find_git_ancestor(fname) or lsputil.path.dirname(fname)
end

return {
    default_config = {
        cmd = { "ruff", "server", "--preview" },
        filetypes = { "python" },
        root_dir = root_dir,
        single_file_support = true,
    },
}
