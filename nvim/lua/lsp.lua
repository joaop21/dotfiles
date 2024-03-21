local nvim_lsp = require("lspconfig")

-- require("mason-lspconfig").setup()

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local on_attach = function(_, bufnr)
  local attach_opts = { silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, attach_opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, attach_opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, attach_opts)
  vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, attach_opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, attach_opts)
end

nvim_lsp.elixirls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  flags = { debounce_text_changes = 150 },
  root_dir = nvim_lsp.util.root_pattern({".git", "mix.exs"})
})

nvim_lsp.lua_ls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim', 'use' }
      }
    }
  }
})

nvim_lsp.tsserver.setup({
  capabilities = capabilities,
  on_attach = on_attach
})
