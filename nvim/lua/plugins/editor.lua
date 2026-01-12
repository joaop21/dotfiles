return {
  -- file explorer
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   keys = {
  --     { "<leader>e", false },
  --     { "<leader>fe", false },
  --     { "<leader>E", false },
  --     { "<leader>fE", false },
  --     {
  --       "<leader>ee",
  --       function()
  --         require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
  --       end,
  --       desc = "Explorer NeoTree (Root Dir)",
  --     },
  --     {
  --       "<leader>ef",
  --       function()
  --         require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd(), reveal = true })
  --       end,
  --       desc = "Explore Current File NeoTree (cwd)",
  --     },
  --   },
  --   opts = {
  --     filesystem = {
  --       filtered_items = {
  --         hide_dotfiles = false,
  --         always_show_by_pattern = { -- uses glob style patterns
  --           ".env*",
  --         },
  --       },
  --     },
  --     window = {
  --       position = "float",
  --     },
  --   },
  -- },

  -- Snacks
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            jump = {
              close = true,
            },
            layout = {
              preset = "default",
            },
          },
        },
      },
    },
  },

  -- Fuzzy finder
  -- {
  --   "nvim-telescope/telescope.nvim",
  --   keys = {
  --     { "<leader>,", false },
  --     { "<leader>/", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
  --     { "<leader><space>", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
  --   },
  --   opts = {
  --     defaults = {
  --       file_ignore_patterns = {
  --         -- "out/",
  --         -- "cache/",
  --         -- "node_modules",
  --         -- "%.git/",
  --         "%_build/",
  --         "%.elixir%_ls",
  --         "deps",
  --       },
  --       layout_config = {
  --         prompt_position = "top",
  --       },
  --       sorting_strategy = "ascending",
  --     },
  --   },
  -- },
  --
  -- {
  --   "ibhagwan/fzf-lua",
  --   keys = {
  --     { "<leader>,", false },
  --     { "<leader>/", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
  --     { "<leader><space>", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
  --   },
  -- },
}
