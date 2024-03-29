return {
    {
        "nvim-lua/plenary.nvim",
        lazy = true,
    },
    {
        "kkharji/sqlite.lua",
        build = function()
            vim.uv.fs_mkdir(vim.fn.stdpath("data") .. "/databases", 511)
        end,
    },
    {
        "stevearc/resession.nvim",
        init = function()
            local e = require("helpers.event")

            local function session_name()
                local cwd = tostring(vim.uv.cwd())
                local obj = vim.system({ "git", "branch", "--show-current" }, { text = true }):wait()

                return obj.code == 0 and string.format("%s-%s", cwd, vim.trim(obj.stdout)) or cwd
            end

            vim.api.nvim_create_user_command("SessionLoad", function()
                require("resession").load(session_name(), { silence_errors = false })

                vim.cmd.doautoall(e.BufReadPost)
            end, { desc = "Session Load" })

            e.on(e.VimLeavePre, function()
                require("resession").save(session_name(), { notify = false })
            end, {
                desc = "Save session on exit.",
            })
        end,
        opts = {
            buf_filter = function(bufnr)
                local buftype = vim.bo[bufnr].buftype
                local ignored = require("config.defaults").ignored

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
    },
    {
        "sQVe/sort.nvim",
        cmd = "Sort",
        keys = {
            { "go", vim.cmd.Sort, desc = "Sort lines or elements" },
            { "go", "<Esc><Cmd>Sort<CR>", mode = "v", desc = "Sort lines or elements" },
        },
        opts = true,
    },
    {
        "axieax/urlview.nvim",
        cmd = "UrlView",
        keys = {
            { "<leader>fu", vim.cmd.UrlView, desc = "URLs" },
        },
        opts = {
            default_action = "system",
            default_picker = "telescope",
            log_level_min = vim.log.levels.ERROR,
        },
    },
    {
        "psliwka/vim-dirtytalk",
        build = ":DirtytalkUpdate",
        config = function()
            table.insert(vim.opt.rtp, vim.fn.stdpath("data") .. "/site")
            vim.opt.spelllang:append("programming")
        end,
        event = "LazyFile",
    },
    {
        "chrishrb/gx.nvim",
        cmd = "Browse",
        config = true,
        keys = { { "gx", vim.cmd.Browse, mode = { "n", "x" }, desc = "Open URL in Browser" } },
    },

    -- Wezterm
    { "justinsgithub/wezterm-types" },

    -- { "lewis6991/fileline.nvim", lazy = false },
}
