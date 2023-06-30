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

vim.keymap.set("n", "<localleader>t", "<cmd>make test -q<cr>", { desc = "Cargo test" })
vim.keymap.set("n", "<localleader>b", "<cmd>make build<cr>", { desc = "Cargo build" })
vim.keymap.set("n", "<localleader>c", "<cmd>make clippy -q<cr>", { desc = "Cargo clippy" })
