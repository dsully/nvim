local M = {}

function M.open(lines, opts)
    --
    opts = vim.tbl_extend("keep", opts or {}, {
        border = vim.g.border,
        winhl = "Normal",
        borderhl = "FloatBorder",
        height = 0.8,
        width = 0.8,
        x = 0.5,
        y = 0.5,
        winblend = 0,
        filetype = "markdown",
        spell = false,
    })

    local cl = vim.o.columns
    local ln = vim.o.lines

    local width = math.ceil(cl * opts.width)
    local height = math.ceil(ln * opts.height - 4)

    -- local dim = M.dimensions(opts)

    local bufnr = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        anchor = "NW",
        style = "minimal",
        width = width,
        col = math.ceil((cl - width) * opts.x),
        row = math.ceil((ln - height) * opts.y - 1),
        height = height,
        border = vim.g.border,
        noautocmd = true,
    })

    -- Handle auto closing on WinLeave
    local close = function()
        vim.api.nvim_win_close(win, true)
        pcall(function()
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end)
    end

    vim.keymap.set("n", "q", close, { silent = true, buffer = bufnr })
    vim.keymap.set("n", "<esc>", close, { silent = true, buffer = bufnr })

    vim.api.nvim_set_option_value("conceallevel", 3, { scope = "local", win = win })
    vim.api.nvim_set_option_value("spell", opts.spell, { scope = "local", win = win })
    vim.api.nvim_set_option_value("filetype", opts.filetype, { scope = "local", win = win })

    vim.api.nvim_set_option_value("winhl", ("Normal:%s"):format(opts.winhl), { scope = "local", win = win })
    vim.api.nvim_set_option_value("winhl", ("FloatBorder:%s"):format(opts.borderhl), { scope = "local", win = win })
    vim.api.nvim_set_option_value("winblend", opts.winblend, { scope = "local", win = win })

    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
    vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(win, { 1, 0 })

    return { bufnr = bufnr, win = win }
end

return M
