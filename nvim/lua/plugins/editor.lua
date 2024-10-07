return {
  -- file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>e", false },
      { "<leader>fe", false },
      { "<leader>E", false },
      { "<leader>fE", false },
      {
        "<leader>ee",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        "<leader>ef",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd(), reveal = true })
        end,
        desc = "Explore Current File NeoTree (cwd)",
      },
    },
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          always_show_by_pattern = { -- uses glob style patterns
            ".env*",
          },
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
