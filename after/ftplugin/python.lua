if package.loaded["mini.pairs"] then
    --
    -- Don't match on the 3rd quote for docstrings.
    require("mini.pairs").map_buf(0, "i", '"', { action = "closeopen", pair = '""', neigh_pattern = '[^\\"][]%s)}\'"]', register = { cr = false } })
end

-- Install dmypy-ls in virtual env if it doesn't exist.
-- This is needed so types can be resolved correctly.
--
-- If/once upstream addresses my PR, then pulling from pypi is an option.
do
    if vim.env.VIRTUAL_ENV and not vim.g.dmypy then
        local dmypy = vim.env.VIRTUAL_ENV .. "/bin/dmypy-ls"

        if not vim.uv.fs_access(dmypy, "RX") then
            vim.notify("Installing dmypy-ls in virtual env...")

            vim.system({ "python", "-m", "pip", "install", vim.env.HOME .. "/src/dmypy-ls/dist/dmypy_ls-1.20-py3-none-any.whl" }, { text = true }, function(obj)
                if obj.code == 0 then
                    vim.notify("dmypy-ls installed!")
                else
                    vim.notify("dmypy-ls failed to install!")
                end
            end)
        end

        vim.g.dmypy = true

        local check = vim.loop.new_check()

        if check then
            check:start(function()
                if vim.uv.fs_access(dmypy, "RX") then
                    check:stop()

                    vim.schedule(function()
                        local common = require("plugins.lsp.common")

                        require("lspconfig")["dmypyls"].setup({
                            capabilities = common.capabilities(),
                            on_attach = common.on_attach,
                        })

                        vim.cmd.doautocmd("FileType")

                        for _, client in pairs(vim.lsp.get_clients({ bufnr = 0, name = "dmypyls" })) do
                            vim.lsp.buf_attach_client(0, client.id)
                        end
                    end)
                end
            end)
        end
    end
end
