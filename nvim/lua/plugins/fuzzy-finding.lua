return {
  {
    "nvim-telescope/telescope.nvim",
		lazy = true,
		cmd = "Telescope",
		version = false,
		dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local actions = require('telescope.actions')

      require('telescope').setup {
        defaults = {
          -- layout_strategy = 'horizontal',
          -- layout_config = {height = 0.9, width = 0.9},
          file_ignore_patterns = {
            "artifacts/",
            "typechain%-types/",
            "node_modules",
            "%_build/",
            "%.elixir%_ls",
            "deps"
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden"
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ['<C-c>'] = actions.close,
              ['<C-w>'] = actions.send_selected_to_qflist +
                  actions.open_qflist,
              ['<C-q>'] = actions.send_to_qflist +
                  actions.open_qflist,
              ['<c-d>'] = actions.delete_buffer
            },
            n = {['<C-c>'] = actions.close}
          }
        }
      }
    end,
    keys = {
      {
        '<leader>o',
        function()
          local telescope = require('telescope.builtin')
          telescope.buffers();
        end,
        desc = "Buffers"
      },
      {
        '<leader>p',
        function()
          local telescope = require('telescope.builtin')
          telescope.find_files({ hidden = true });
        end,
        desc = "Files"
      },
      {
        '<leader>fw',
        function()
          local telescope = require('telescope.builtin')
          telescope.grep_string();
        end,
        desc = "Search for word under cursor"
      },
      {
        '<leader>ff',
        function()
          local telescope = require('telescope.builtin')
          telescope.grep_string({ search = '' });
        end,
        desc = "Search for input"
      }
    },
  }
}
