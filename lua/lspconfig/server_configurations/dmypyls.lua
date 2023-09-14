return {
    default_config = {
        cmd = { "dmypy-ls" },
        filetypes = { "python" },
        root_dir = function(fname)
            local lsputil = require("lspconfig.util")
            local markers = {
                "Pipfile",
                "pyproject.toml",
                "pyrightconfig.json",
                "setup.py",
                "setup.cfg",
                "requirements.txt",
            }
            return lsputil.root_pattern(unpack(markers))(fname) or lsputil.find_git_ancestor(fname) or lsputil.path.dirname(fname)
        end,
        single_file_support = true,
    },
}
