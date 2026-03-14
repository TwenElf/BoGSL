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
- `GameDef(board, pieces, assignedPieces, actions, flow, rules, players)`
- `BoardDef(width, height)`
- `PieceDef(name, moves)`
- `PieceAssignmentDef(playerId, pieceId, typeId, direction, initialPosition)`
- `PositionDef(x, y)`
- `MoveDef(name, steps)`
- `ActionDef(pieceId, moveId)`
- `FlowDef` (`flowDef(startState, endState, states)`)
- `StateDef(name, transitions)`
- `TransitionDef(event, toState)`
- `RuleDef` (`gameRuleDef(ruleId)`, `pieceRuleDef(pieceId, ruleId)`)
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
- extracts first `Board`, `Chest`, `Actions`, and `Players` subtree
- extracts required `Flow` subtree
- extracts game-wide rules from top-level `GameRuleProperty` (`rule: <ID>`)
- extracts piece-wide rules from `PieceRuleProperty` inside each piece (`rule: <ID>`)
- maps board integers to `BoardDef`
- maps every `Piece` (type) to `PieceDef`
- maps every `PlayerDefinition` `id` to the `players` list
- maps every `PieceAssignment` (nested inside each `PlayerDefinition`) to `PieceAssignmentDef`
- maps `FacingDirection` to `Facing`
- maps `Movement` and `Direction` to `MoveDef` and `Step`
- maps each `Action` to `ActionDef`
- maps each `FlowState` to `StateDef`
- maps each state transition edge (`event -> target`) to `TransitionDef`
- maps game-wide and piece-wide rule properties to `RuleDef`
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
- duplicate piece type IDs (`DuplicatePiece`)
- duplicate move IDs inside one piece type (`DuplicateMove`)
- duplicate assigned piece IDs (`DuplicateAssignedPiece`)
- assigned piece references unknown player (`UnknownAssignedPiecePlayer`)
- assigned piece references unknown type (`UnknownAssignedPieceType`)
- duplicate assigned positions (`DuplicateAssignedPiecePosition`)
- assigned piece placed outside board bounds (`AssignedPieceOutOfBounds`)
- missing player declarations (`MissingPlayers`)
- duplicate players (`DuplicatePlayer`)
- action points to unknown assigned piece (`UnknownActionPiece`)
- action points to unknown move for that assigned piece type (`UnknownActionMove`)
- duplicate flow states (`DuplicateFlowState`)
- duplicate flow transitions (`DuplicateFlowTransition`)
- unknown flow start/end states (`UnknownFlowStart`, `UnknownFlowEnd`)
- unknown flow transition targets (`UnknownFlowTransitionTarget`)
- unreachable flow end state (`UnreachableFlowEnd`)
- duplicate game-wide rules (`DuplicateGameRule`)
- duplicate piece-wide rules per piece (`DuplicatePieceRule`)
- piece-wide rules that target unknown pieces (`UnknownPieceRulePiece`)

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

g = parseGameModelFile(|cwd:///example/chess.dsl|);
errs = checkGameModelFile(|cwd:///example/chess.dsl|);
```

`g` contains the normalized game model.
`errs` contains all semantic errors found in that model.
Use `example/chess.dsl` for a chess-like sample covering node-based flow, one game rule, `enPassant` as a piece rule on `pawn`, and explicit per-player piece placement.
