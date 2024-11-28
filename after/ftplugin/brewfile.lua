-- Override some default Ruby colors for Homebrew Bundle files.
vim.api.nvim_set_hl(0, "@function.call.ruby", { link = "Keyword" })
vim.api.nvim_set_hl(0, "@symbol.ruby", { link = "Special" })

ev.on(ev.BufWritePre, function(args)
    if args.file:match("Brewfile.tmpl") then
        return
    end

    local entries = {}
    local lines = {}
    local categories = { "tap", "brew", "cask", "mas", "vscode" }

    for _, category in ipairs(categories) do
        entries[category] = {}
    end

    -- Collect existing entries from the buffer.
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, true)) do
        for category, entry in line:gmatch("(%w+) (.+)") do
            table.insert(entries[category], entry)
        end
    end

    for _, category in ipairs(categories) do
        local hash = {}

        -- The actual sort.
        table.sort(entries[category])

        for _, item in ipairs(entries[category]) do
            -- Ensure we don't have duplicates.
            if not hash[item] then
                hash[item] = true

                table.insert(lines, category .. " " .. item)
            end
        end
    end

    vim.api.nvim_buf_set_lines(0, 0, #lines + 1, false, lines)
end, {
    desc = "Sort Brewfiles properly by category on write.",
    pattern = { "brewfile", "brewfile.*" },
})
