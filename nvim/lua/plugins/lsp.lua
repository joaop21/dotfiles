return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "williamboman/mason.nvim",
      lazy = false,
      dependencies = {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        opts = { 
          automatic_installation = true 
        },
      },
      opts = { 
        ui = { 
          icons = { 
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          } 
        } 
      }
    }
  }
}
