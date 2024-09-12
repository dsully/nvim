-- Install dmypy-ls in virtual env if it doesn't exist.
-- This is needed so types can be resolved correctly.
--
-- If/once upstream addresses my PR, then pulling from pypi is an option.
local function dmypy_ls()
    if vim.env.VIRTUAL_ENV and not vim.g.dmypy then
        local dmypy = vim.env.VIRTUAL_ENV .. "/bin/dmypy-ls"
        local python = vim.env.VIRTUAL_ENV .. "/bin/python"

        if not vim.uv.fs_access(python, "RX") then
            return
        end

        if not vim.uv.fs_access(dmypy, "RX") then
            vim.notify("Installing dmypy-ls in virtual env...")

            local pip = vim.env.VIRTUAL_ENV .. "/bin/pip"
            local args

            if vim.uv.fs_access(pip, "RX") then
                args = { "python", "-m", "pip", "install", vim.g.home .. "/src/dmypy-ls/dist/dmypy_ls-1.20-py3-none-any.whl" }
            else
                args = { "uv", "pip", "install", "dmypy-ls" }
            end

            vim.system(args, { text = true }, function(obj)
                if obj.code == 0 then
                    vim.notify("dmypy-ls installed!")
                else
                    vim.notify("dmypy-ls failed to install!")
                end
            end)
        end

        vim.g.dmypy = true

        local check = vim.uv.new_check()

        if check then
            check:start(function()
                if vim.uv.fs_access(dmypy, "RX") then
                    check:stop()

                    vim.schedule(function()
                        require("lspconfig")["dmypyls"].setup({
                            capabilities = require("helpers.lsp").capabilities(),
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

vim.schedule(dmypy_ls)
