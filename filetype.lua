-- Custom file types
vim.filetype.add({
    filename = {
        [".envrc"] = "direnv",
        [".flake8"] = "ini",
        [".rgignore"] = "gitignore",
        ["Brewfile"] = "brewfile",
        ["Caddyfile"] = "caddyfile",
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
        ivy = "xml",
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
        [".*/%.github/workflows/.*%.[ya]ml"] = "yaml.ghaction",
        [".*/.config/ghostty/config"] = "ghostty",
        [".*/themes?/.*%.theme"] = "fish",
        ["Brewfile.*"] = "brewfile",
        ["Dockerfile.*"] = function(path)
            return path:match("%.dockerignore%*?$") and "gitignore" or "dockerfile"
        end,
        [".yml$"] = function(path)
            return path:find("compose") and "yaml.docker-compose" or "yaml"
        end,
    },
})
