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
  },
  {
    name = "Oil",
    url = "https://github.com/stevearc/oil.nvim",
    config = function()
      require("Oil").setup()
    end
  },
  {
    name = "nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter").setup()
    end,
  },
  {
    name = "headlines",
    url = "https://github.com/lukas-reineke/headlines.nvim",
    config = function()
      require("headlines").setup()
    end,
  },
}
