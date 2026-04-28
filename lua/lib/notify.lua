local config = {
    -- existing kinds: https://neovim.io/doc/user/ui.html#ui-messages
    msgKind = {
        ignore = { "search_cmd", "return_prompt" },
        mini = { "bufwrite", "undo" }, -- more minimal style when using `snacks.notifier`
    },
    notification = { icon = "󰍩" },
}

--------------------------------------------------------------------------------

local ns = vim.api.nvim_create_namespace("ui-hack")

local function attach()
    ---@diagnostic disable-next-line: redundant-parameter incomplete annotation from nvim core
    vim.ui_attach(ns, { ext_messages = true }, function(event, ...)
        if event == "msg_history_show" then
            local msgs = ...

            local out = vim.iter(msgs)
                :map(function(entry)
                    return vim.iter(entry[2])
                        :map(function(msg)
                            return msg[2]
                        end)
                        :totable()
                end)
                :map(table.concat)
                :totable()

            vim.notify(table.concat(out, "\n\n"), nil, {
                title = ":messages",
                icon = config.notification.icon,
            })
        end

        if event ~= "msg_show" then
            return
        end

        -- ignore & deal with "press enter to continue" prompts
        local kind, content, _replace, _history = ... -- for `msg_show` only https://neovim.io/doc/user/ui.html#ui-messages
        kind = tostring(kind)

        if kind == "return_prompt" then -- SIC we're still being blocked, thus need to feedkey `<CR>`
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, true, true), "n", false)
        end

        if vim.list_contains(config.msgKind.ignore, kind) then
            return
        end

        -- notification text and options
        local text = vim.iter(content):fold("", function(acc, chunk)
            return acc .. chunk[2]
        end)

        text = vim.trim(text):gsub("^(E%d+):", "[%1]") -- colorize error code when using `snacks`

        local level = ({
            wmsg = vim.log.levels.WARN,
        })[kind] or vim.log.levels.INFO

        if kind == "emsg" or vim.endswith(kind, "error") or vim.endswith(kind, "err") then
            level = vim.log.levels.ERROR
        end

        local opts = { title = kind, icon = config.notification.icon }
        opts.ft = ({ lua_print = "lua" })[kind]
        if vim.list_contains(config.msgKind.mini, kind) and package.loaded["snacks"] then
            opts.style = "minimal"
            opts.icon = " " .. opts.icon .. " "
        end

        vim.schedule(function()
            vim.notify(text, level, opts)
        end)
    end)
end

local function detach()
    vim.ui_detach(ns)
end

--------------------------------------------------------------------------------

local group = vim.api.nvim_create_augroup("ui-hack", { clear = true })
vim.api.nvim_create_autocmd({ "CmdlineLeave", "VimEnter" }, { group = group, callback = attach })
vim.api.nvim_create_autocmd("CmdlineEnter", { group = group, callback = detach })
