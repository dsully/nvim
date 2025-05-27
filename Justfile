# Generate EmmyLua configuration with all lazy.nvim plugins
emmylua-config:
    #!/usr/bin/env fish
    set lazy_dirs (find $XDG_DATA_HOME/nvim/lazy -maxdepth 1 -type d | tail -n +2 | sort)

    set json_content '{
        "$schema": "https://raw.githubusercontent.com/EmmyLuaLs/emmylua-analyzer-rust/refs/heads/main/crates/emmylua_code_analysis/resources/schema.json",
        "diagnostics": {
            "disable": [
                "missing-fields",
                "type-not-found",
                "undefined-field"
            ],
            "globals": [
                "Snacks",
                "bit",
                "colors",
                "defaults",
                "ev",
                "hl",
                "keys",
                "ns",
                "package",
                "require",
                "vim"
            ],
            "unusedLocalExclude": [
                "_*"
            ]
        },
        "runtime": {
            "version": "LuaJIT"
        },
        "workspace": {
            "enableReindex": true,
            "library": [
                "$VIMRUNTIME"'
    for dir in $lazy_dirs
        set dir (string replace $XDG_DATA_HOME '$XDG_DATA_HOME' $dir)
        set json_content "$json_content,
                \"$dir\""
    end

    set json_content "$json_content
            ]
        }
    }"

    echo $json_content > .emmyrc.json
    echo "Generated .emmyrc.json with" (count $lazy_dirs) "lazy.nvim plugins"
