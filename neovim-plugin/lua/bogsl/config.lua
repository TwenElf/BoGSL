local jar = require("bogsl.jar")
local M = {}

---@class BogslConfig
---@field jar BogslConfigJar

---@class BogslConfigJar
---@field rascal string
---@field rascal_lsp string
---@field bogsl string

---@type BogslConfig
M.default = {
  jar = {
    rascal = jar.get_rascal_jar(),
    rascal_lsp = jar.get_rascal_lsp_jar(),
    bogsl = jar.get_bogsl_jar(),
  },
}

---@type BogslConfig
M.config = vim.tbl_deep_extend("force", M.default, {})

return M
