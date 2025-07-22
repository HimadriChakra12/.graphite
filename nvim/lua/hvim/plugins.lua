return {
  {
    name = "telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim",
    dependencies = {
      {
        name = "plenary.nvim",
        url = "https://github.com/nvim-lua/plenary.nvim"
      }
    },
    config = function()
      require("telescope").setup()
    end
  },
  {
    name = "buffer-manager.nvim",
    url = "https://github.com/xsoder/buffer-manager.nvim",
    dependencies = {
      {
        name = "telescope.nvim",
        url = "https://github.com/nvim-telescope/telescope.nvim"
      },
      {
        name = "nvim-web-devicons",
        url = "https://github.com/nvim-tree/nvim-web-devicons"
      },
      {
        name = "fzf-lua",
        url = "https://github.com/ibhagwan/fzf-lua"
      },
    },
    config = function()
      require("buffer-manager").setup()
    end
  },
}
