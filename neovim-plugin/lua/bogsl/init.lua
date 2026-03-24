local config = require("bogsl.config")
local util = require("bogsl.util")
local M = {}

---Generate the LSP command from the current config.
---@return string[]
function M.generate_lsp_command()
  local classpath = config.config.jar.rascal_lsp .. ":" .. config.config.jar.rascal
    -- https://github.com/usethesource/rascal-language-servers/blob/4ef17204f9bc15dabc05f9a88b9fa837eb92a633/rascal-vscode-extension/src/lsp/RascalLSPConnection.ts#L160
  return {
    "java",
    "-Dlog4j2.configurationFactory=org.rascalmpl.vscode.lsp.log.LogJsonConfiguration",
    "-Dlog4j2.level=DEBUG",
    "-Drascal.fallbackResolver=org.rascalmpl.vscode.lsp.uri.FallbackResolver",
    "-Drascal.lsp.deploy=true",
    "-Drascal.compilerClasspath=" .. classpath,
    "-cp",
    classpath,
    "org.rascalmpl.vscode.lsp.parametric.ParametricLanguageServer",
    vim.json.encode({
      pathConfig = "pathConfig(srcs=[" .. util.to_rascal_jar_loc(config.config.jar.bogsl ) .." ])",
      name = "BoGSL",
      extensions = {"dsl"},
      mainModule = "LanguageServer",
      mainFunction = "languageServices"
    }),
  }
end

---Set configuration for this plugin.
---@param opts BogslConfig
function M.setup(opts)
  config.config = vim.tbl_deep_extend("force", config.default, opts)
end

return M
