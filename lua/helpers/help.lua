local M = {}

M.popup = function(event)
    --
    local filetype = vim.bo[event.buf].filetype
    local file_path = event.match

    if file_path:match("/doc/") ~= nil then
        --
        if filetype == "help" or filetype == "markdown" then
            local help_win = vim.api.nvim_get_current_win()

            require("helpers.float").open({
                filetype = filetype,
                lines = vim.api.nvim_buf_get_lines(event.buf, 0, -1, false),
                window = {
                    anchor = "E",
                },
            })

            -- Close the initial help split window.
            vim.api.nvim_win_close(help_win, false)
        end
    end
end

return M
