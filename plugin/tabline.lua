-- Native buffer tabline (see lua/lib/tabline.lua for the renderer).
local tabline = require("lib.tabline")

vim.o.tabline = "%!v:lua.require'lib.tabline'.render()"

for i = 1, 9 do
    -- stylua: ignore
    keys.map("<leader>" .. i, function() tabline.focus(i) end, "which_key_ignore")
    -- stylua: ignore
    keys.map(string.format("<M-%d>", i), function() tabline.focus(i) end, "which_key_ignore")
end

ev.on(
    ev.DiagnosticChanged,
    vim.schedule_wrap(function()
        vim.cmd("redrawtabline")
    end),
    { desc = "Redraw tabline on diagnostics" }
)
