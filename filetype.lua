vim.filetype.add({
    filename = {
        [".envrc"] = "direnv",
        [".flake8"] = "ini",
        [".rgignore"] = "gitignore",
        ["Brewfile"] = "brewfile",
        ["Caddyfile"] = "caddyfile",
        ["MANIFEST.in"] = "pymanifest",
        ["config.custom"] = "sshconfig",
        ["fish_history"] = "yaml",
        ["poetry.lock"] = "toml",
        -- Set a specific filetype to enable ruff and taplo to attach as language servers.
        ["pyproject.toml"] = "toml.pyproject",
    },
    extension = {
        conf = "conf",
        ivy = "xml",
        j2 = "htmldjango",
        jinja = "htmldjango",
        jinja2 = "htmldjango",
        log = "log",
        pdl = "pdl",
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
        tmpl = function(filename, _)
            -- Handle chezmoi dot_
            filename = filename:gsub(".tmpl", ""):gsub("dot_", ".")

            -- Attempt with buffer content and filename
            --- @type string?
            local filetype = vim.filetype.match({ filename = filename }) or ""

            if not filetype then
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

                for index, line in ipairs(lines) do
                    if string.match(line, "{{") then
                        table.remove(lines, index) -- remove tmpl lines
                    end
                end

                if not filetype then
                    filetype = vim.filetype.match({ filename = filename, contents = lines }) -- attempt without tmpl lines

                    if not filetype then
                        filetype = vim.filetype.match({ contents = lines }) -- attempt without filename
                    end
                end
            end

            if filetype then
                return filetype .. ".gotexttmpl"
            end
        end,
    },
    pattern = {
        ["*.dockerignore"] = "gitignore",
        ["*Caddyfile*"] = "caddyfile",
        [".*/themes?/.*%.theme"] = "fish",
        [".*/.github/workflows/.*%.yaml"] = "yaml.ghaction",
        [".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
        [".*requirements%.in"] = "requirements",
        [".*requirements%.txt"] = "requirements",
        ["Brewfile.*"] = "brewfile",
        ["Dockerfile.*"] = function(path)
            if path:find(".dockerignore*$") then
                return "gitignore"
            end

            return "dockerfile"
        end,
        [".*%.yml"] = function(path)
            if path:find(".*compose.*$") then
                return "yaml.docker-compose"
            end

            return "yaml"
        end,
        [".*"] = function(_path)
            return vim.bo.filetype ~= "large_file" and require("helpers.file").is_large_file() and "large_file" or nil
        end,
    },
})
