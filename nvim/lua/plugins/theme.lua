return {
 {
    "navarasu/onedark.nvim",
    lazy = false,
    config = function()
      require('onedark').setup {
        style = 'deep'
      }
      require('onedark').load()
    end,
 }
}
