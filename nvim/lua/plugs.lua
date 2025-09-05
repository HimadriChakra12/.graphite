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
}
