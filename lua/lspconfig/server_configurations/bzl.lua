return {
    default_config = {
        cmd = { "bzl", "lsp", "serve" },
        filetypes = { "bazel" },
        root_dir = require("lspconfig.util").root_pattern("WORKSPACE", "WORKSPACE.bazel", "MODULE.bazel"),
        single_file_support = true,
    },
}
