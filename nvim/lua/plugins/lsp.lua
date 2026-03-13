return {
  "neovim/nvim-lspconfig",
  version = "*",
  opts = {
    servers = {
      expert = {
        cmd = { "/Users/joao/.local/share/nvim/mason/bin/expert", "--stdio" },
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern("mix.exs", ".git")(fname)
        end,
        filetypes = { "elixir", "eelixir", "heex" },
      },
    },
  },
}
