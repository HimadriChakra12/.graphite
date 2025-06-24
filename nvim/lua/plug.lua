-- /lua/..
require('keybindings')
require('netwr')

-- /pack/..
require('telescope').setup{}
require('neogit').setup{}
require('buffer-manager').setup{}

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
require('plugins.pcmp').setup()
require("plugins.bufshift")
require("plugins.markdown")
require("plugins.explo")
require("plugins.zox").setup() 
require("plugins.termim").setup()
require("plugins.gcc")
require("plugins.shell")

-- require("goyomd")
