return {
  -- "neovim/nvim-lspconfig",
  -- opts = {
  --   inlay_hints = { enabled = false },
  --   servers = {
  --     eslint = {
  --       root_dir = function()
  --         local lazyvimRoot = require("lazyvim.util.root")
  --         return lazyvimRoot.git()
  --       end,
  --     },
  --     ts_ls = {
  --       root_dir = function()
  --         local lazyvimRoot = require("lazyvim.util.root")
  --         return lazyvimRoot.git()
  --       end,
  --     },
  --     vtsls = {
  --       root_dir = function()
  --         local lazyvimRoot = require("lazyvim.util.root")
  --         return lazyvimRoot.git()
  --       end,
  --     },
  --   },
  -- },
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      eslint = {
        root_dir = function()
          local lazyvimRoot = require("lazyvim.util.root")
          return lazyvimRoot.git()
        end,
        settings = {
          useFlatConfig = true, -- set if using flat config
          experimental = {
            useFlatConfig = nil, -- option not in the latest eslint-lsp
          },
        },
      },
    },
    setup = {
      eslint = function()
        require("lazyvim.util").lsp.on_attach(function(client)
          if client.name == "eslint" then
            client.server_capabilities.documentFormattingProvider = true
          elseif client.name == "tsserver" or client.name == "vtsls" then
            client.server_capabilities.documentFormattingProvider = false
          end
        end)
      end,
    },
  },
}
