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
    name = "buffer-manager",
    url = "https://github.com/xsoder/buffer-manager.nvim.git",
    dependencies = {
      { url = "https://github.com/nvim-tree/nvim-web-devicons" },
      { url = "https://github.com/ibhagwan/fzf-lua" },
    },
    config = function()
      require("buffer-manager").setup()
    end,
  },
  {
    name = "NeoGit",
    url = "https://github.com/xsoder/neogit",
    config = function()
      require("NeoGit").setup()
    end
  },  {
    name = "nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter")
    end,
  },  {
    name = "Oil",
    url = "https://github.com/stevearc/oil.nvim",
    dependencies = {
      { url = "https://github.com/echasnovski/mini.nvim" },
      { url = "https://github.com/nvim-tree/nvim-web-devicons" },
    },
    config = function()
        require("oil")
    end,
},
  {
    name = "Undotree",
    url = "https://github.com/mbbill/undotree",
    config = function()
      require("Undotree").setup()
    end,
  },
  {
    name = "gruvbox",
    url = "https://github.com/ellisonleao/gruvbox.nvim.git",
    config = function()
      require("gruvbox")
    end,
  },
}
