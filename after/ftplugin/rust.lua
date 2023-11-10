local cmd = require("config.defaults").cmd
vim.keymap.set("n", "<leader>ce", function()
    ---
    vim.lsp.buf_request(0, "experimental/openCargoToml", {
        textDocument = vim.lsp.util.make_text_document_params(0),
    }, function(_, result, ctx)
        --
        if result ~= nil then
            vim.lsp.util.jump_to_location(result, vim.lsp.get_client_by_id(ctx.client_id).offset_encoding)
        end
    end)
end, { desc = "Open Cargo.toml" })

vim.cmd.compiler("cargo")

vim.keymap.set("n", "<localleader>t", cmd("make test -q"), { desc = "Cargo test" })
vim.keymap.set("n", "<localleader>b", cmd("make build"), { desc = "Cargo build" })
vim.keymap.set("n", "<localleader>c", cmd("make clippy -q"), { desc = "Cargo clippy" })

--
if package.loaded["mini.pairs"] then
    local mp = require("mini.pairs")

    mp.map_buf(0, "i", "<", { action = "open", pair = "<>", neigh_pattern = "[%a:].", register = { cr = false } })
    mp.map_buf(0, "i", ">", { action = "close", pair = "<>", register = { cr = false } })

    -- Don't close single quote if we're in a lifetime position.
    mp.map_buf(0, "i", "'", { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\<&].", register = { cr = false } })
end
