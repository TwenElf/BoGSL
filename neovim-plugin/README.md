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
    .. " && mkdir -p target/tmp"
    .. " && curl -L https://github.com/usethesource/rascal-language-servers/releases/download/v0.13.3/rascalmpl-0.13.3.vsix -o target/tmp/rascal.zip"
    .. " && unzip -o target/tmp/rascal.zip -d target/tmp"
    .. " && mv target/tmp/extension/assets/jars/rascal.jar target"
    .. " && mv target/tmp/extension/assets/jars/rascal-lsp.jar target",
}
```

> [!Note]
> The snippet above extracts the latest release VSCode extension,
> but this is a bit hacky.
> When Rascal LSP 2.22.3 and Rascal 0.42.1 get released on [Maven](https://mvnrepository.com/search?q=rascal),
> you should download the `jar` files from there instead.

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
