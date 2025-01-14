---@type LazySpec
return {
    "stevearc/oil.nvim",
    keys = {
        { "<leader>o", vim.cmd.Oil, desc = "Oil: Open" },
    },
    opts = function()
        -- Helper function to parse output
        local function parse_output(proc)
            local result = proc:wait()
            local ret = {}

            if result.code == 0 then
                for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
                    -- Remove trailing slash
                    line = line:gsub("/$", "")
                    ret[line] = true
                end
            end

            return ret
        end

        -- Build git status cache
        local function new_git_status()
            return setmetatable({}, {
                __index = function(self, key)
                    local ignore_proc = vim.system({ "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" }, {
                        cwd = key,
                        text = true,
                    })
                    local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
                        cwd = key,
                        text = true,
                    })
                    local ret = {
                        ignored = parse_output(ignore_proc),
                        tracked = parse_output(tracked_proc),
                    }

                    rawset(self, key, ret)
                    return ret
                end,
            })
        end

        local git_status = new_git_status()

        -- Clear git status cache on refresh
        local refresh = require("oil.actions").refresh
        local orig_refresh = refresh.callback

        refresh.callback = function(...)
            git_status = new_git_status()
            orig_refresh(...)
        end

        ---@module "oil"
        ---@type oil.SetupOpts
        return {
            columns = {
                "icon",
                "permissions",
                "size",
                "mtime",
            },
            confirmation = {
                border = defaults.ui.border.name,
            },
            float = {
                border = defaults.ui.border.name,
            },
            keymaps = {
                ["q"] = { "actions.close", mode = "n" },
            },
            keymaps_help = {
                border = defaults.ui.border.name,
            },
            lsp_file_methods = {
                autosave_changes = true,
            },
            progress = {
                border = defaults.ui.border.name,
            },
            ssh = {
                border = defaults.ui.border.name,
            },
            view_options = {
                view_options = {
                    is_hidden_file = function(name, bufnr)
                        local dir = require("oil").get_current_dir(bufnr)
                        local is_dotfile = vim.startswith(name, ".") and name ~= ".."

                        -- If no local directory (e.g. for ssh connections), just hide dotfiles
                        if not dir then
                            return is_dotfile
                        end

                        -- Dotfiles are considered hidden unless tracked
                        if is_dotfile then
                            return not git_status[dir].tracked[name]
                        else
                            return git_status[dir].ignored[name]
                        end
                    end,
                },
                -- show_hidden = true,
                sort = {
                    { "type", "asc" },
                    { "name", "asc" },
                },
            },
            watch_for_changes = true,
        }
    end,
}
