-- Custom file types
vim.filetype.add({
    filename = {
        [".envrc"] = "direnv",
        [".flake8"] = "ini",
        [".rgignore"] = "gitignore",
        ["Brewfile"] = "brewfile",
        ["Caddyfile"] = "caddyfile",
        ["Cargo.toml"] = "toml.cargo",
        ["PklProject"] = "pkl",
        ["config.custom"] = "sshconfig",
        ["direnvrc"] = "direnv",
        ["fish_history"] = "yaml",
        ["poetry.lock"] = "toml",
        -- Set a specific filetype to enable ruff and taplo to attach as language servers.
        ["pyproject.toml"] = "toml.pyproject",
        ["uv.lock"] = "toml",
    },
    extension = {
        age = "age",
        conf = "conf",
        gotmpl = "gotmpl",
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
            return require("helpers.file").template_type(filename, "j2", "jinja")
        end,
        tmpl = function(filename, _)
            return require("helpers.file").template_type(filename, "tmpl", "gotmpl")
        end,
    },
    pattern = {
        ["*.dockerignore"] = "gitignore",
        [".*/%.github[%w/]+workflows[%w/]+.*%.ya?ml"] = "yaml.github",
        [".*/.config/ghostty/config"] = "ghostty",
        [".*/themes?/.*%.theme"] = "fish",
        ["Brewfile.*"] = "brewfile",
        ["Dockerfile.*"] = function(path)
            return path:match("%.dockerignore%*?$") and "gitignore" or "dockerfile"
        end,
        [".yml$"] = function(path)
            return path:find("compose") and "yaml.docker-compose" or "yaml"
        end,
        ["requirements[%w_.-]+%.txt"] = "requirements",
    },
} --[[@as vim.filetype.add.filetypes ]])
