-- https://github.com/apple/sourcekit-lsp
---@type vim.lsp.Config
return {
    cmd = { "sourcekit-lsp" },
    filetypes = {
        "c",
        "cpp",
        "objc",
        "objcpp",
        "swift",
    },
    root_dir = function(bufnr, on_dir)
        local filename = nvim.file.filename(bufnr)

        on_dir(
            string.find(filename, "buildServer.json")
                or string.find(filename, ".xcodeproj")
                or string.find(filename, ".xcworkspace")
                or string.find(filename, "compile_commands.json")
                or string.find(filename, "Package.swift")
        )
    end,
    root_markers = { "Package.swift" },
    telemetry = {
        enabled = false,
    },
}
