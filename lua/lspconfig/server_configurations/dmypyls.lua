local root_dir = function()
    return vim.fs.root(0, {
        "Pipfile",
        "pyproject.toml",
        "pyrightconfig.json",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        ".git",
    })
end

local find_command = function()
    local gcommand = "dmypy-ls"

    if vim.env.VIRTUAL_ENV then
        local vcommand = vim.env.VIRTUAL_ENV .. "/bin/" .. gcommand

        if vim.uv.fs_stat(vcommand) then
            gcommand = vcommand
        end
    end

    return { gcommand, "--chdir", root_dir() }
end

return {
    default_config = {
        cmd = find_command(),
        filetypes = { "python" },
        root_dir = root_dir,
        single_file_support = true,
    },
}
