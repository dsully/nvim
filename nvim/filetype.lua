vim.filetype.add({
    filename = {
        [".envrc"] = "bash",
        [".flake8"] = "ini",
        ["Brewfile"] = "Brewfile",
        ["Caddyfile"] = "caddyfile",
        ["MANIFEST.in"] = "pymanifest",
        ["config.custom"] = "sshconfig",
        ["fish_history"] = "yaml",
        ["poetry.lock"] = "toml",
    },
    extension = {
        conf = "conf",
        j2 = "htmldjango",
        jinja = "htmldjango",
        jinja2 = "htmldjango",
        plist = "xml", -- macOS PropertyList files
        -- We always want LaTeX, avoid slow detection logic
        tex = "latex",
        -- Heuristic that only sets the filetype to C++ if the header file includes
        -- another C++-style header (i.e. one without a trailing .h):
        h = function(_, _)
            if vim.fn.search("\\C^#include <[^>.]\\+>$", "nw") ~= 0 then
                return "cpp"
            end
            return "c"
        end,
        tmpl = function(_, _)
            if vim.fn.search('{{.\\+}}', 'nw') then
                return "gotmpl"
            end
        end,
    },
    pattern = {
        ["*Caddyfile*"] = "caddyfile",
        [".*requirements*.in"] = "requirements",
        [".*requirements*.txt"] = "requirements",
    },
})
