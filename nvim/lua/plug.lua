-- /lua/..
require('keybindings')
require('netwr')

-- /pack/..
require('telescope').setup{}
require('neogit').setup{}
require('buffer-manager').setup{}
--require('markdown-preview').setup{}
--require('headlines').setup{}
-- Example Treesitter configuration (adjust based on your actual setup)
-- /csode/..
require("csode.options")
require("csode.local").load() -- Load local plugins

-- /lua/statusline..
require("status.theme")
require("status.style")

-- /lua/startup..
require("startups.startup4")
require("startups.startup1")

-- /lua/plugins..
--require("plugins.shell")
require('plugins.pcmp').setup()
require("plugins.bufshift")
require("plugins.markdown")
-- require("plugins.tree") --[Replaced with explorer.lua]
require("plugins.explo")
require("plugins.zox").setup() 
require("plugins.termim").setup()
require("plugins.gcc")
require("plugins.shell")

-- require("plugins.zoxvim").setup() --[Replaced with zox.lua]
-- require("plugins.ff") [Replaced by telescope.nvim]
-- require("plugins.explorer")
-- require("scope").setup() [Replaced with telescope.nvim]


 --require("zen-mode").setup {
 --  window = {
 --    backdrop = 0.98,
 --    width = 100,  -- adjust width to your liking
 --    height = 40,
 --  },
 --  plugins = {
 --    options = {
 --      enabled = true,
 --      ruler = false,
 --      showcmd = false,
 --    },
 --  },
 --}
-- Auto-enable Goyo for markdown files
--vim.api.nvim_create_autocmd("FileType", {
--  pattern = "markdown",
--  command = "Goyo",
--})
--
---- Quit Neovim when Goyo is closed (after auto-launch)
--vim.api.nvim_create_autocmd("User", {
--  pattern = "GoyoLeave",
--  callback = function()
--    -- Only quit if the filetype is markdown and we're in Goyo mode
--    if vim.bo.filetype == "markdown" then
--      vim.cmd("q")
--    end
--  end,
--})
--
---- Map :bd to exit Goyo and close buffer + quit nvim if in Goyo mode
--vim.keymap.set("n", ":bd", function()
--  if vim.fn.exists("#User#GoyoEnter") == 1 then
--    vim.cmd("Goyo!")
--  end
--  vim.cmd("bd")
--  vim.cmd("q")
--end, { expr = false })
