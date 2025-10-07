---@type LazySpec
return {
    "jmbuhr/otter.nvim",
    keys = {
        {
            "<leader>os",
            function()
                local otterkeeper = require("otter.keeper")
                local main_nr = vim.api.nvim_get_current_buf()
                local langs = {}

                for i, l in ipairs(otterkeeper.rafts[main_nr].languages) do
                    langs[i] = i .. ": " .. l
                end

                -- Prompt to choose one of langs
                local i = vim.fn.inputlist(langs)
                local lang = otterkeeper.rafts[main_nr].languages[i]
                local params = {
                    textDocument = vim.lsp.util.make_text_document_params(),
                    otter = {
                        lang = lang,
                    },
                }
                local clients = vim.lsp.get_clients({
                    -- the client is always named otter-ls[<buffnr>]
                    name = "otter-ls" .. "[" .. main_nr .. "]",
                })

                if #clients == 1 then
                    local otter_client = clients[1]
                    otter_client:request("textDocument/documentSymbol", params, nil)
                end
            end,
            desc = "Otter Symbols",
        },
    },
    event = ev.VeryLazy,
    opts = {
        lsp = {
            root_dir = function(_, bufnr)
                return vim.fs.root(bufnr or 0, {
                    ".git",
                    "flake.nix",
                    "Justfile",
                    "package.json",
                    "pyproject.toml",
                }) or vim.fn.getcwd(0)
            end,
        },
        -- Add event listeners for LSP events for debugging
        debug = true,
        verbose = { -- set to false to disable all verbose messages
            no_code_found = true, -- warn if otter.activate is called, but no injected code was found
        },
    },
}
