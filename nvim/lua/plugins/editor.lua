return {
  -- file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>e", false },
      { "<leader>ee", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
      {
        "<leader>ef",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root(), reveal = true })
        end,
        desc = "Explorer Current File NeoTree (Root Dir)",
      },
    },
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
        },
      },
      window = {
        position = "float",
      },
    },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>,", false },
    },
  },
}
