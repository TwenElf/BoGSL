# AST Pipeline

This document explains how BoGSL moves from parsed syntax to a semantic model.

## Why an AST exists
The concrete syntax tree is good for parsing, but it is not ideal for game logic checks.
The AST gives a normalized structure that is easier to validate and execute.

Pipeline:
- source text (`.dsl`)
- parse tree (`Game`, `Chest`, `Piece`, ...)
- AST (`GameDef`, `PieceDef`, `MoveDef`, ...)
- semantic errors (`SemanticError`)

## `Model.rsc`
`Model.rsc` defines the core AST data types:
- `GameDef(board, pieces, actions)`
- `BoardDef(width, height)`
- `PieceDef(name, directions, moves)`
- `MoveDef(name, steps)`
- `ActionDef(pieceId, moveId)`
- `Facing` (`northFacing`, `southFacing`, `eastFacing`, `westFacing`)
- `Step` (`forwardStep`, `backwardStep`, `leftStep`, `rightStep`)

Design intent:
- keep syntax-independent game concepts
- preserve game identifiers (`pieceId`, `moveId`) for cross-reference checks
- represent movement as directional steps

## `ToModel.rsc`
`ToModel.rsc` converts parse trees from `Syntax.rsc` into AST values from `Model.rsc`.

Main entrypoint:
- `toModel(Game gameTree) -> GameDef`

What it does:
- extracts first `Board`, `Chest`, and `Actions` subtree
- maps board integers to `BoardDef`
- maps every `Piece` to `PieceDef`
- maps `FacingDirection` to `Facing`
- maps `Movement` and `Direction` to `MoveDef` and `Step`
- maps each `Action` to `ActionDef`
- throws explicit conversion errors when required parse-tree parts are missing

What it intentionally does not do:
- global semantic validation (duplicate IDs, unknown references, etc.)
- execution semantics for moves

Those are handled in `Checks.rsc` and future interpreter/executor modules.

## `Checks.rsc`
`Checks.rsc` performs semantic validation on `GameDef`.

Main entrypoint:
- `checkSemantics(GameDef game) -> list[SemanticError]`

Current checks:
- duplicate piece IDs (`DuplicatePiece`)
- missing piece direction (`MissingPieceDirection`)
- multiple piece directions (`MultiplePieceDirections`)
- duplicate move IDs inside one piece (`DuplicateMove`)
- action points to unknown piece (`UnknownActionPiece`)
- action points to unknown move for an existing piece (`UnknownActionMove`)

## Parser API integration
`Parser.rsc` exposes AST and semantic-check helpers:
- `parseGameFile(loc) -> Game` (trim + parse + structural `checkGame`)
- `parseGame(str) -> Game` (trim + parse + structural `checkGame`)
- `parseGameModelFile(loc) -> GameDef`
- `parseGameModel(str) -> GameDef`
- `checkGameModelFile(loc) -> list[SemanticError]`
- `checkGameModel(str) -> list[SemanticError]`

Related helpers:
- `parseChestFile(loc) -> Chest` (trim + parse)
- `parseChest(str) -> Chest` (trim + parse)

## Usage example
In Rascal REPL:

```rascal
import Parser;

g = parseGameModelFile(|file:///Users/gbianchi/dev/BoGSL/src/main/rascal/exampleGame2.dsl|);
errs = checkGameModelFile(|file:///Users/gbianchi/dev/BoGSL/src/main/rascal/exampleGame2.dsl|);
```

`g` contains the normalized game model.
`errs` contains all semantic errors found in that model.
