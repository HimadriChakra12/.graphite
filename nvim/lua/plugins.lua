return {
  {
    name = "telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim.git",
    config = function()
      require("telescope.nvim")
    end,
    dependencies = {
      { name = "plenary.nvim", url = "https://github.com/nvim-lua/plenary.nvim.git" },
    }
  },
  {
    name = "NeoGit",
    url = "https://github.com/xsoder/NeoGit",
    config = function()
      require("NeoGit")
    end,
  },
  {
    name = "buffer_manager.nvim",
    url = "https://github.com/xsoder/buffer-manager.nvim.git",
    config = function()
      require("buffer_manager.nvim")
    end,
    dependencies = {
      { name = "nvim-web-devicons", url = "https://github.com/nvim-tree/nvim-web-devicons" },
      { name = "fzf-lua", url = "https://github.com/ibhagwan/fzf-lua" },
    }
  },
}
