---@type LazySpec
return {
    ---@module 'resession'
    "stevearc/resession.nvim",
    config = function(_, opts)
        local resession = require("resession")

        resession.setup(opts)

        resession.add_hook("post_load", function()
            --
            -- Loop over all available buffer and attach to `help` buffers
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                --
                if vim.bo[buf].ft == "help" then
                    require("helpview").actions.attach(buf)
                end
            end
        end)
    end,
    init = function()
        --
        ---@return string
        local root = function()
            return Snacks.git.get_root() or nvim.file.cwd()
        end

        nvim.command("SessionLoad", function()
            local resession = require("resession")

            if vim.tbl_isempty(resession.list()) then
                vim.notify("No saved sessions", vim.log.levels.WARN)
            end

            local ok, _ = pcall(resession.load, root(), { silence_errors = false })

            if not ok then
                vim.notify("No session to restore!")
                Snacks.picker.explorer()
            end
        end, { desc = "Session Load" })

        ev.on(ev.VimLeavePre, function()
            require("resession").save(root(), { notify = false })
        end, {
            desc = "Save session on exit.",
        })
    end,
    opts = {
        buf_filter = function(bufnr)
            local buftype = vim.bo[bufnr].buftype
            local ignored = defaults.ignored

            if buftype ~= "" and buftype ~= "acwrite" then
                return false
            end

            if vim.tbl_contains(ignored.buffer_types, buftype) or vim.tbl_contains(ignored.file_types, vim.bo[bufnr].filetype) then
                return false
            end

            local cwd = nvim.file.cwd()

            for _, pattern in ipairs(ignored.paths) do
                if cwd:find(nvim.file.escape_pattern(tostring(vim.fn.expand(pattern)))) then
                    return false
                end
            end

            return vim.bo[bufnr].buflisted
        end,
    },
    priority = 100, -- Load before the dashboard.
}
