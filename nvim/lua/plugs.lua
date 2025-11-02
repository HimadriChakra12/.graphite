return {
    {
        name = "telescope",
        url = "https://github.com/nvim-telescope/telescope.nvim",
        dependencies = {
            { url = "https://github.com/nvim-lua/plenary.nvim" },
        },
        config = function()
            require("telescope")
        end
    },
    {
        name = "Undotree",
        url = "https://github.com/mbbill/undotree",
        config = function()
            require("Undotree").setup()
        end,
    },
    {
        name = "vim-dadbod",
        url = "https://github.com/tpope/vim-dadbod",
        config = function()
            require("vim-dadbod")
        end,
    },
    {
        name = "vim-dadbod-ui",
        url = "https://github.com/kristijanhusak/vim-dadbod-ui",
        config = function()
            require("vim-dadbod")
        end,
    },
    {
        name = "fugitive",
        url = "https://github.com/tpope/vim-fugitive",
        config = function()
            require("fugitive")
        end,
    },
    {
        name = "buffer_manager",
        url = "https://github.com/j-morano/buffer_manager.nvim",
        config = function()
            require("buffer_manager")
        end,
    },
    {
        name = "nvim-autopairs",
        url = "https://github.com/windwp/nvim-autopairs",
        config = function()
            require('nvim-autopairs').setup({
                disable_in_macro = true, -- disable when recording or executing a macro
                disable_in_visualblock = false, -- disable when insert after visual block mode
                disable_in_replace_mode = true,
                ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
                enable_moveright = true,
                enable_afterquote = true, -- add bracket pairs after quote
                enable_check_bracket_line = true, --- check bracket in same line
                enable_bracket_in_quote = true, --
                enable_abbr = false, -- trigger abbreviation
                break_undo = true, -- switch for basic rule break undo sequence
                check_ts = false,
                map_cr = true,
                map_bs = true, -- map the <BS> key
                map_c_h = false, -- Map the <C-h> key to delete a pair
                map_c_w = false, -- map <c-w> to delete a pair if possible
            })
        end,
    },
  {
    name = "nord",
    url = "https://github.com/shaunsingh/nord.nvim.git",
    config = function()
    end,
  },
}
