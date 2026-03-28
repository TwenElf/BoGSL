# BoGSL VSCode extension

The BoGSL VSCode extension adds the BoGSL LSP to VSCode (and forks of VSCode).

## Requirements

- JDK 11
  - If this isn't installed, the extension can install JDK 11 for you

## Building

With

- NodeJS
- Maven

installed, run

```sh
npx vsce package
```

This will create a `.vsix` file that can be installed in VSCode by clicking

1. _Extensions_ (on the sidebar)
2. The three dots on the top right in the drawer
3. _Install from VSIX..._
