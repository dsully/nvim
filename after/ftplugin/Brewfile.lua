local e = require("helpers.event")

-- Override some default Ruby colors for Homebrew Bundle files.
vim.api.nvim_set_hl(0, "@function.call.ruby", { link = "Keyword" })
vim.api.nvim_set_hl(0, "@symbol.ruby", { link = "Special" })

e.on(e.BufWritePre, function()
    local entries = {}
    local lines = {}

    -- Collect existing entries from the buffer.
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, true)) do
        for category, entry in line:gmatch("(%l+) (.+)") do
            if not entries[category] then
                entries[category] = { entry }
            else
                table.insert(entries[category], entry)
            end
        end
    end

    for _, category in ipairs({ "tap", "brew", "cask", "mas", "vscode" }) do
        if entries[category] then
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
    end

    vim.api.nvim_buf_set_lines(0, 0, #lines, false, lines)
end, {
    desc = "Sort Brewfiles properly by category on write.",
    pattern = "Brewfile",
})
