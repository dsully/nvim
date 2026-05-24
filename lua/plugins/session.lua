---@type zpack.Spec
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

        -- Written on exit only when leaving via Neovim 0.12+'s `:restart`
        -- (v:exitreason == "restart"), then consumed on the next launch.
        local restart_marker = vim.fn.stdpath("state") .. "/restart"

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
            local name = root()
            require("resession").save(name, { notify = false })

            local listed = 0

            for _, b in ipairs(vim.api.nvim_list_bufs()) do
                if vim.bo[b].buflisted then
                    listed = listed + 1
                end
            end

            -- Record the exact session name so the relaunch loads *this* session,
            -- not whatever root() resolves to in the new process (`:restart` may
            -- change cwd / git root, which would load a stale session).
            if vim.v.exitreason == "restart" then
                nvim.file.write(restart_marker, name)
            end
        end, {
            desc = "Save session on exit.",
        })

        -- After `:restart`, bypass the dashboard and restore the just-saved
        -- session. VimEnter runs before snacks opens the dashboard on UIEnter;
        -- loading the session repopulates the first window so the dashboard's
        -- open check bails out. File args (always dropped by :restart) skip this.
        ev.on(ev.VimEnter, function()
            local name = nvim.file.read(restart_marker)

            if vim.fn.argc(-1) ~= 0 then
                return
            end

            if not name or name == "" then
                return
            end

            vim.uv.fs_unlink(restart_marker)

            pcall(require("resession").load, vim.trim(name), { silence_errors = true })

            local listed = 0

            for _, b in ipairs(vim.api.nvim_list_bufs()) do
                if vim.bo[b].buflisted then
                    listed = listed + 1
                end
            end
        end, {
            desc = "Restore session after :restart.",
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

            -- Don't save buffers that are currently readonly - avoids persisting transient readonly state.
            if vim.bo[bufnr].readonly then
                return false
            end

            return vim.bo[bufnr].buflisted
        end,
        extensions = {
            tabline = {},
        },
    },
    priority = 100, -- Load before the dashboard.
}
