-- Custom file types
vim.filetype.add({
    filename = {
        [".envrc"] = "direnv",
        [".flake8"] = "ini",
        [".rgignore"] = "gitignore",
        ["Brewfile"] = "brewfile",
        ["Caddyfile"] = "caddy",
        ["Chart.yaml"] = "helm",
        ["config.custom"] = "sshconfig",
        ["PklProject"] = "pkl",
        ["direnvrc"] = "direnv",
        ["fish_history"] = "yaml",
        ["poetry.lock"] = "toml",
        ["uv.lock"] = "toml",
    },
    extension = {
        age = "age",
        conf = "conf",
        gotmpl = function(filename, _)
            return require("lib.file").template_type(filename, "gotmpl", "gotmpl")
        end,
        jinja = "jinja",
        jinja2 = "jinja",
        pcf = "pkl",
        pkl = "pkl",
        plist = "xml.plist", -- macOS PropertyList files
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
        j2 = function(filename, _)
            return require("lib.file").template_type(filename, "j2", "jinja")
        end,
        tmpl = function(filename, _)
            return require("lib.file").template_type(filename, "tmpl", "gotmpl")
        end,
    },
    pattern = {
        [".*/%.github[%w/]+workflows[%w/]+.*%.ya?ml"] = "yaml.github",
        [".*/layouts/.*%.html"] = "gohtmltmpl",
        [".*/templates/.*%.tpl"] = "helm",
        [".*/templates/.*%.ya?ml"] = "helm",
        [".*/themes?/.*%.theme"] = "fish",
        [".*/zed/settings.json"] = "jsonc",
        [".yml$"] = function(path)
            return path:find("compose") and "yaml.docker-compose" or "yaml"
        end,
        ["*.dockerignore"] = "gitignore",
        ["Brewfile.*"] = "brewfile",
        [".*Dockerfile.*"] = function(path)
            return path:match("%.dockerignore%*?$") and "gitignore" or "dockerfile"
        end,
        ["helmfile.*%.ya?ml"] = "helm",
        ["requirements[%w_.-]+%.txt"] = "requirements",
    },
} --[[@as vim.filetype.add.filetypes ]])
