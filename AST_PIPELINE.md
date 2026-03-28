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
- `MoveDef(name, steps)` or `MoveDef(name, steps, rule)` (when an inline movement rule is attached)
- `ActionDef(pieceId, moveId)`
- `FlowDef` (`flowDef(startState, endState, states)`)
- `StateDef(name, transitions)`
- `TransitionDef(event, toState)`
- `RuleDef`:
  - `gameRuleDef(ruleId, logic)` — named game-level rule (from `rules` block, no type tag)
  - `moveRuleDef(ruleId, logic)` — `Movement` rule (game-level or movement-level)
  - `startTurnRuleDef(ruleId, logic)` — `StartTurn` rule
  - `endTurnRuleDef(ruleId, logic)` — `EndTurn` rule
  - `pieceRuleDef(pieceId, ruleId)` — piece-level reference to a named rule
- `RuleLogic` — recursive rule logic expression tree (see `Model/Rule.rsc`)
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
- extracts first `Board`, `Chest`, and `Players` subtree
- extracts optional `Actions` subtree (defaults to empty action list if absent)
- extracts required `Flow` subtree
- extracts game-level rules from the `rules: { ... }` block (`Rule` nodes with `RuleType` and `RuleParts`)
- extracts movement-level inline rules from `Rule` nodes attached to individual `Movement` definitions
- extracts piece-level rule references from `PieceRuleProperty` nodes (`rule: <ID>`) inside each piece
- maps board integers to `BoardDef`
- maps every `Piece` (type) to `PieceDef`
- maps every `PlayerDefinition` `id` to the `players` list
- maps every `PieceAssignment` (nested inside each `PlayerDefinition`) to `PieceAssignmentDef`
- maps `FacingDirection` to `Facing`
- maps `Movement` and `Direction` to `MoveDef` and `Step`
- maps each `Action` to `ActionDef`
- maps each `FlowState` to `StateDef`
- maps each state transition edge (`event -> target`) to `TransitionDef`
- maps game-level and movement-level `Rule` trees to `RuleDef` (with full `RuleLogic`)
- maps piece-level `PieceRuleProperty` references to `pieceRuleDef`
- throws explicit conversion errors when required parse-tree parts are missing

What it intentionally does not do:
- global semantic validation (duplicate IDs, unknown references, etc.)
- execution semantics for moves

Those are handled in `Checks.rsc` and `Gameplay.rsc`.

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
- flow state names that are not player IDs or `gameOver` (`InvalidFlowStateActor`)
- flow start that is not a player ID (`InvalidFlowStartPlayer`)
- flow end that is not `gameOver` (`InvalidFlowEndState`)
- ambiguous multiple transitions for one flow event in one state (`AmbiguousFlowEventTransition`)
- missing required `moved`/`noMoves` transitions in non-`gameOver` states (`MissingFlowEventTransition`)
- duplicate flow transitions (`DuplicateFlowTransition`)
- unknown flow start/end states (`UnknownFlowStart`, `UnknownFlowEnd`)
- unknown flow transition targets (`UnknownFlowTransitionTarget`)
- unreachable flow end state (`UnreachableFlowEnd`)
- duplicate game-wide rules (`DuplicateGameRule`)
- duplicate piece-wide rules per piece (`DuplicatePieceRule`)
- piece-wide rules that target unknown pieces (`UnknownPieceRulePiece`)

## Runtime flow wiring (`Gameplay.rsc`)

Gameplay now follows the flow machine directly:
- `availableMoves(game, state, playerId)` computes legal candidate moves for one player
- `doFlowTurn(state, game)` executes one turn and triggers either `moved` or `noMoves`
- `doFlowGameplay(game)` iterates flow transitions until `end` is reached (`gameOver`)

Transition resolution is event-based:
- if the current player has at least one legal move, one is executed and event `moved` is emitted
- otherwise event `noMoves` is emitted

## `Display.rsc`
`Display.rsc` provides a terminal-based board inspection utility:
- `displayASCIIBoard(board, state)` – prints the board with piece names in their current cells, with row/column labels.

Useful for debugging gameplay state outside the browser UI.

## `UI.rsc`
`UI.rsc` implements the interactive browser UI using [Salix](https://github.com/usethesource/salix).

Key functions:
- `startUI(game, state) → UIApp` – builds the Salix app; returns a `UIApp` (`App[UIState]`) for IDE/REPL use.
- `serveUI(game, state, host)` – wraps `startUI` and immediately starts a standalone HTTP server on `host` in non-daemon mode (used by `bogsl.sh`).

What it renders:
- Board grid with pieces in their current positions; cells and piece labels highlight when a move targets that cell.
- Action buttons for every available move; clicking a button executes `doAction` + `advanceFlow("moved")`.
- A "Continue" button when no moves are available, triggering `advanceFlow("noMoves")`.
- A live Mermaid flow chart with the current state highlighted.

## `BoGSL.rsc`
`BoGSL.rsc` is the top-level entry point module.

- `playBoGSL(loc) → UIApp` – parses + checks (`parseCheckGameModelFile`) + starts the UI. Returns a `UIApp` for IDE rendering.
- `playChess()` – convenience wrapper for `example/chess.dsl`.
- `playLine()` – convenience wrapper for `example/line.dsl`.
- `main(list[str] args)` – invoked by `bogsl.sh`; takes `[absPath, port]` and calls `serveUI`.

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
Use `example/chess.dsl` for a chess-like sample covering node-based flow, a `rules` block with three game-level Movement rules, movement-level inline rules on pawn moves, and explicit per-player piece placement.
