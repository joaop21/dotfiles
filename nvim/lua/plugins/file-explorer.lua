return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = true,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    hijack_cursor = true,
    disable_netrw = true,
    sync_root_with_cwd = true,
    view = {
      side = "right",
      preserve_window_proportions = true,
    },
    filters = {
      custom = { "^\\.DS_Store" }
    },
  },
  keys = {
    {
      '<leader>nn',
      function() require('nvim-tree.api').tree.toggle() end,
      desc = "Toggle"
    },
    {
      '<leader>nf',
      function()
          require('nvim-tree.api').tree.find_file({
              open = true,
              focus = true
          })
      end,
      desc = "Find file"
    }
  }
}
