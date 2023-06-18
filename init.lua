if vim.loader then
    vim.loader.enable()
end

require("config.autocommands")
require("config.keymaps")
require("config.options")
require("config.lazy")
