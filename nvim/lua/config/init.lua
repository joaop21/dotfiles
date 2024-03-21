---@class Config: Options
local M = {}

---@class Options
local defaults = {
  -- icons used by other plugins
  icons = {
    diagnostics = {
      Error = " ",
      Warn  = " ",
      Hint  = " ",
      Info  = " ",
    },
  },
}

setmetatable(M, {
  __index = function(_, key)
    return vim.deepcopy(defaults)[key]
  end,
})

return M
