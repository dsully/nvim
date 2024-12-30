return {
    "stevearc/resession.nvim",
    init = function()
        vim.api.nvim_create_user_command("SessionLoad", function()
            require("resession").load(require("helpers.file").git_root(), { silence_errors = false })
        end, { desc = "Session Load" })

        ev.on(ev.VimLeavePre, function()
            require("resession").save(require("helpers.file").git_root(), { notify = false })
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

            local cwd = tostring(vim.uv.cwd())

            for _, pattern in ipairs(ignored.paths) do
                if cwd:find(require("helpers.file").escape_pattern(tostring(vim.fn.expand(pattern)))) then
                    return false
                end
            end

            return vim.bo[bufnr].buflisted
        end,
    },
    priority = 100, -- Load before alpha.nvim
}
