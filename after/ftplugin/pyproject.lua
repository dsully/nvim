ev.on(ev.BufWritePost, function()
    --
    if nvim.file.is_local_dev() then
        require("overseer").run_template({ name = "uv" })
    end
end, {
    desc = "Run uv sync when pyproject.toml is written."
})
