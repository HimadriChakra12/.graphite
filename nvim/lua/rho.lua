-- /lua/..
require('keybindings')
-- require('netwr')
require("pacman.bricks")
require("headlines")
require("plugs")
require("dashboard")
-- require("buffer-manager").setup()
require("autoload").ld()

-- /csode/..
-- require("csode.options")
require("pacman.ghost").setup()

-- /lua/statusline..
require("statusbar.style")
require("statusbar.theme")

-- /lua/snippets..
-- require("snippets.markdown")
require("snippets.html").setup()
-- require("snippets.goyomd")

-- lua/plugins..
require("plugins.nvim_compile")
require("plugins.lsp")
require("plugins.markdown_link_nav")
require('plugins.pcmp').setup()
require("plugins.buffershift")
require("plugins.explorer")
require("plugins.zoxide").setup() 
require("plugins.termin").setup()
require("plugins.shell")
require("plugins.pin")
require("plugins.browser")

-- pacman
require("telescope")
require("NeoGit").setup()
require("buffer-manager").setup()
