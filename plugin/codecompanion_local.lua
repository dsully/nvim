-- Load optional out-of-tree codecompanion extensions from $CODECOMPANION_PATH.
--
-- This is a local, non-git plugin, so it can't go through vim.pack/zpack. It's
-- the native equivalent of lazy.nvim's `dir` spec: prepend the directory to the
-- runtimepath and source its plugin/ scripts so they populate
-- _G.codecompanion_local_adapters before codecompanion's config runs.
local path = vim.env.CODECOMPANION_PATH

if not path or path == "" or not vim.uv.fs_stat(path) then
    return
end

vim.opt.runtimepath:prepend(path)

-- Newly added runtimepath entries are not auto-sourced (startup already
-- enumerated plugin/), so source them explicitly.
for _, file in ipairs(vim.fn.globpath(path .. "/plugin", "**/*.lua", false, true)) do
    vim.cmd.source(file)
end
