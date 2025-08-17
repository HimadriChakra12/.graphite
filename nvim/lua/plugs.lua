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
        name = "Undotree",
        url = "https://github.com/mbbill/undotree",
        config = function()
            require("Undotree").setup()
        end,
    },
}
