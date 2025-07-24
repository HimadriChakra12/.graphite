-- /lua/..
require('keybindings')
-- require('netwr')
require("pacman.ghost").setup()
require("headlines")

-- /csode/..
require("csode.options")
require("csode.local").load() -- Load local plugins

-- /lua/statusline..
require("statusbar.style")
require("statusbar.theme")

-- /lua/startup..
require("dashboard.startup4")
require("dashboard.startup1")

-- /lua/snippets..
-- require("snippets.markdown")
require("snippets.html").setup()
-- require("snippets.goyomd")

-- /lua/plugins..
require('plugins.pcmp').setup()
require("plugins.buffershift")
require("plugins.explorer")
require("plugins.zoxide").setup() 
require("plugins.termin").setup()
-- require("plugins.gcc")
require("plugins.shell")
require("plugins.pin")

