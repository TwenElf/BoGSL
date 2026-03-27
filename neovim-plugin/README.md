# BoGSL Neovim plugin

The BoGSL Neovim plugin adds the BoGSL LSP to Neovim.

## Requirements

For building the LSP:

- Maven

During runtime:

- JDK 11
- Rascal and Rascal LSP `.jar` files
  - The configuration below downloads the needed `.jar` files

## Installation

Using lazy.nvim:

```lua
{
  "TwenElf/BoGSL",
  config = function(plugin)
    vim.opt.rtp:append(plugin.dir .. "/neovim-plugin")
    require("lazy.core.loader").packadd(plugin.dir .. "/neovim-plugin")
    require("bogsl").setup({})
  end,
  build = "mvn package"
    .. " && curl https://cdn.jsdelivr.net/npm/@usethesource/rascal-vscode-dsl-lsp-server@0.13.3/assets/jars/rascal.jar -o target/rascal.jar"
    .. " && curl https://cdn.jsdelivr.net/npm/@usethesource/rascal-vscode-dsl-lsp-server@0.13.3/assets/jars/rascal-lsp.jar -o target/rascal-lsp.jar",
}
```

## Usage

This plugin can be configured by passing a table of options to the `setup` function.
The default configuration of this plugin is

```lua
{
  jar = {
    rascal = jar.get_rascal_jar(),
    rascal_lsp = jar.get_rascal_lsp_jar(),
    bogsl = jar.get_bogsl_jar(),
  },
}
```

- `jar`: location of the JAR files of Rascal to use for the terminal.
  By default, the plugin assumes that all JAR files are in `target`.

### LSP

To enable the LSP, use

```lua
vim.lsp.enable("bogsl_lsp")
```

The JAR files specified in the config are used to start the LSP.

See [lsp/rascal_lsp.lua](lsp/rascal_lsp.lua) for details.
