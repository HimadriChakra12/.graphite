-- /lua/..
require('keybindings')
-- require('netwr')
require('plugins.local').load()
require("pacman.ghost").setup()
require("headlines")
require("plugs")

-- /csode/..
require("csode.options")

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
