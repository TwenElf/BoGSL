local bogsl = require("bogsl")

return {
  name = "bogsl_lsp",
  cmd = bogsl.generate_lsp_command(),
  filetypes = { "bogsl" },
}
