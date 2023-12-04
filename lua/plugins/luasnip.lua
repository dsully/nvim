return {
    "L3MON4D3/LuaSnip",
    cmd = { "LuaSnipEdit" },
    config = function()
        local ls = require("luasnip")
        local types = require("luasnip.util.types")

        -- documentation for snippet format inside examples:
        -- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua

        ls.config.set_config({
            keep_roots = true,
            link_roots = true,
            link_children = true,
            -- Do not jump to snippet if I'm outside of it
            -- https://github.com/L3MON4D3/LuaSnip/issues/78
            region_check_events = "CursorMoved",
            delete_check_events = "TextChanged",
            enable_autosnippets = true,
            ext_opts = {
                [types.choiceNode] = {
                    active = {
                        virt_text = { { "", "Operator" } },
                        hl_mode = "combine",
                    },
                },
                [types.insertNode] = {
                    active = {
                        virt_text = { { "", "Type" } },
                        hl_mode = "combine",
                    },
                },
            },
            -- Use treesitter for getting the current filetype. This allows correctly resolving
            -- the current filetype in eg. a markdown-code block or `vim.cmd()`.
            ft_func = require("luasnip.extras.filetype_functions").from_cursor,
        })

        -- Snippets are stored in separate files.
        require("luasnip.loaders.from_lua").load({ paths = vim.api.nvim_get_runtime_file("lua/snippets", false)[1] })

        -- Friendly snippets.
        require("luasnip.loaders.from_vscode").lazy_load()

        -- Create a command to edit the snippet file associated with the current
        vim.api.nvim_create_user_command("LuaSnipEdit", function()
            require("telescope")
            require("luasnip.loaders").edit_snippet_files()
        end, {})

        vim.keymap.set({ "i" }, "<C-k>", function()
            if ls.expand_or_jumpable() then
                ls.expand_or_jump()
            end
        end, { silent = true, desc = "Expand or jump to next snippet node" })

        vim.keymap.set({ "i", "s" }, "<C-l>", function()
            ls.jump(1)
        end, { silent = true, desc = "Jump to next snippet node" })

        vim.keymap.set({ "i", "s" }, "<C-j>", function()
            ls.jump(-1)
        end, { silent = true, desc = "Jump to previous snippet node" })

        vim.keymap.set({ "i", "s" }, "<C-e>", function()
            if ls.choice_active() then
                ls.change_choice(1)
            end
        end, { silent = true, desc = "Select previous choice in snippet choice nodes" })

        vim.keymap.set({ "i", "n" }, "<C-s>", function()
            ls.unlink_current()
        end, { silent = true, desc = "Clear snippet jumps" })
    end,
    dependencies = { "rafamadriz/friendly-snippets" },
}
