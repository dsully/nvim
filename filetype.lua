-- Custom file types
vim.filetype.add({
    filename = {
        [".duckdbrc"] = "sql",
        [".env"] = "ini",
        [".envrc"] = "sh",
        [".flake8"] = "ini",
        [".rgignore"] = "gitignore",
        ["Brewfile"] = "brewfile",
        ["Caddyfile"] = "caddy",
        ["config.custom"] = "sshconfig",
        ["PklProject"] = "pkl",
        ["direnvrc"] = "sh",
        ["fish_history"] = "yaml",
        ["poetry.lock"] = "toml",
        ["uv.lock"] = "toml",
    },
    extension = {
        age = "age",
        conf = "conf",
        jinja = "jinja",
        jinja2 = "jinja",
        jsonl = "json",
        ndjson = "json",
        pcf = "pkl",
        pkl = "pkl",
        plist = "xml.plist", -- macOS PropertyList files
        -- .m defaults to MATLAB in Neovim; in this (Apple) context it is
        -- Objective-C. sourcekit-lsp attaches on the "objc" filetype, so this
        -- mapping is required for both LSP and the correct tree-sitter grammar.
        m = "objc",
        -- We always want LaTeX, avoid slow detection logic
        tex = "latex",
        -- Objective-C headers first (Apple codebase), then fall back to the
        -- C-vs-C++ heuristic: C++ only if the header includes an extensionless
        -- C++-style header (i.e. one without a trailing .h):
        h = function(_, _)
            if vim.fn.search("\\C\\(@interface\\|@protocol\\|@property\\|#import\\|NS_ASSUME_NONNULL\\)", "nw") ~= 0 then
                return "objc"
            end
            if vim.fn.search("\\C^#include <[^>.]\\+>$", "nw") ~= 0 then
                return "cpp"
            end
            return "c"
        end,
        j2 = function(filename, _)
            return require("lib.file").template_type(filename, "j2", "jinja")
        end,
    },
    pattern = {
        ["%.env%..*"] = "ini",
        [".*/%.github[%w/]+workflows[%w/]+.*%.ya?ml"] = "yaml.github",
        [".*/layouts/.*%.html"] = "gohtmltmpl",
        [".*/zed/settings.json"] = "jsonc",
        [".*%.log"] = function()
            return "log"
        end,
        [".*%.log%.txt"] = function()
            return "log"
        end,
        [".yml$"] = function(path)
            return path:find("compose") and "yaml.docker-compose" or "yaml"
        end,
        ["*.dockerignore"] = "gitignore",
        ["Brewfile.*"] = "brewfile",
        [".*Dockerfile.*"] = function(path)
            return path:match("%.dockerignore%*?$") and "gitignore" or "dockerfile"
        end,
        ["requirements[%w_.-]+%.txt"] = "requirements",
    },
} --[[@as vim.filetype.add.filetypes ]])
