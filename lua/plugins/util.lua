return {
    { "nvim-lua/plenary.nvim" },
    { "MunifTanjim/nui.nvim" },
    {
        "stevearc/resession.nvim",
        config = function(_, opts)
            local resession = require("resession")
            local lazy_open = false

            resession.setup(opts)

            resession.add_hook("post_load", function()
                -- Fixes lazy freaking out when a session is loaded and there are auto-installs being run.
                if lazy_open then
                    require("lazy.view").show()
                    lazy_open = false
                end

                vim.cmd.doautoall(ev.BufReadPost)
                vim.cmd.doautoall(ev.SessionLoadPost)
            end)

            resession.add_hook("pre_load", function()
                local view = require("lazy.view")

                if view.view then
                    lazy_open = true

                    if view.view:buf_valid() then
                        vim.api.nvim_buf_delete(view.view.buf, { force = true })
                    end
                    view.view:close({ wipe = true })
                else
                    lazy_open = false
                end

                require("lspconfig")
            end)
        end,
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
        "vhyrro/toml-edit.lua",
        build = "rockspec",
        priority = 1000,
    },
    -- Pretty screen shots.
    {
        "mistricky/codesnap.nvim",
        build = "make build_generator",
        cmd = {
            "CodeSnap",
            "CodeSnapSave",
        },
        keys = {
            { "<leader>cS", "", desc = "󰹑 Screen Shots", mode = { "x" } },
            { "<leader>cSs", "<cmd>CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
            { "<leader>cSS", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "Save selected code snapshot in ~/Pictures" },
        },
        opts = {
            bg_theme = "dusk",
            has_breadcrumbs = true,
            save_path = vim.env.XDG_PICTURES_DIR,
            watermark = "",
        },
    },
    -- { "lewis6991/fileline.nvim", lazy = false },
}
