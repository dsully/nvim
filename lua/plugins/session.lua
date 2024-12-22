return {
    "stevearc/resession.nvim",
    init = function()
        local function session_name()
            local cwd = tostring(vim.uv.cwd())
            local obj = vim.system({ "git", "branch", "--show-current" }, { text = true }):wait()

            return obj.code == 0 and string.format("%s-%s", cwd, vim.trim(obj.stdout)) or cwd
        end

        vim.api.nvim_create_user_command("SessionLoad", function()
            require("resession").load(session_name(), { silence_errors = false })
        end, { desc = "Session Load" })

        ev.on(ev.VimLeavePre, function()
            require("resession").save(session_name(), { notify = false })
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

            --- Escape special pattern matching characters in a string
            ---@param input string
            ---@return string
            local function escape_pattern(input)
                local magic_chars = { "%", "(", ")", ".", "+", "-", "*", "?", "[", "^", "$" }

                for _, char in ipairs(magic_chars) do
                    input = input:gsub("%" .. char, "%%" .. char)
                end

                return input
            end

            local cwd = tostring(vim.uv.cwd())

            for _, pattern in ipairs(ignored.paths) do
                if cwd:find(escape_pattern(tostring(vim.fn.expand(pattern)))) then
                    return false
                end
            end

            return vim.bo[bufnr].buflisted
        end,
    },
    priority = 100, -- Load before alpha.nvim
}
