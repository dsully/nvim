-- vim: ft=lua
-- luacheck: ignore
---@diagnostic disable: lowercase-global

-- Rerun tests only if their modification time changed.
cache = true

-- Emit warning codes in error output.
codes = true

-- List of warnings: https://luacheck.readthedocs.io/en/stable/warnings.html
ignore = {
    -- "121", -- setting read-only global variable 'vim'
    "122", -- Indirectly setting a readonly global
    "212/_.*", -- unused argument, for vars with "_" prefix
    -- "411", -- Redefining a local variable.
    -- "412", -- Redefining an argument.
    -- "422", -- Shadowing an argument
    "631", -- max_line_length
}

include_files = {
    "after/**/*.lua",
    "filetype.lua",
    "init.lua",
    "lua/**/*.lua",
    "plugin/*.lua",
}

-- max_cyclomatic_complexity = 2

---@diagnostic disable-next-line: undefined-global
globals = {
    "vim.g",
    "vim.b",
    "vim.w",
    "vim.o",
    "vim.bo",
    "vim.wo",
    "vim.go",
    "vim.env",
}

read_globals = {
    "LazyVim",
    "Snacks",
    "colors",
    "defaults",
    "ev",
    "hl",
    "keys",
    "notify",
    "package",
    "vim",
}

-- Don't report unused self arguments of methods.
self = false

std = "luajit"
