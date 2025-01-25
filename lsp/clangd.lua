---@type vim.lsp.Config
return {
    cmd = {
        "clangd",
        "--clang-tidy",
        "--background-index",
        "--offset-encoding=utf-8",
    },
    filetypes = { "c", "cpp", "java", "cuda", "proto" },
    init_options = {
        clangdFileStatus = true,
        completeUnimported = true,
        usePlaceholders = true,
        semanticHighlighting = true,
    },
    root_markers = {
        ".clangd",
        "Makefile",
        "build.ninja",
        "compile_commands.json",
        "configure.in",
        "meson.build",
    },
    settings = {
        clangd = {
            semanticHighlighting = true,
            single_file_support = false,
        },
    },
    single_file_support = true,
}
