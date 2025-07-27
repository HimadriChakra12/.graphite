local M = {}

M.load = function()
    require("plugins.nvim_compile")
    require("plugins.markdown_link_nav")
    require('plugins.pcmp').setup()
    require("plugins.buffershift")
    require("plugins.explorer")
    require("plugins.zoxide").setup() 
    require("plugins.termin").setup()
    require("plugins.shell")
    require("plugins.pin")
    require("plugins.browser")
end

return M
