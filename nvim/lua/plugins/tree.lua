
-- Netrw Settings to Make It Look Like an IDE File Explorer
vim.g.netrw_banner = 0        -- Hide the banner
-- vim.g.netrw_liststyle = 2     -- Use tree view
vim.g.netrw_browse_split = 0  -- Open files in the same window
vim.g.netrw_winsize = 10      -- Set Netrw window size
-- vim.g.netrw_altv = 1          -- Open files in vertical split
-- vim.g.netrw_keepdir = 0       -- Allow browsing outside of CWD
vim.g.netrw_localcopydircmd = 'cp -r' -- Copy directories recursively

-- Keybind to Open Netrw Easily (Like an IDE File Explorer)
vim.api.nvim_set_keymap("n", "<leader>e", ":Explore<CR>", { noremap = true, silent = true })

