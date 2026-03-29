# BoGSL
A grid-based board game specific language (DSL), created for the Software Language Engineering course at Vrije Universiteit Amsterdam (2026).

## Project layout
- `pom.xml`
- `META-INF/RASCAL.MF`
- `bogsl.sh` (CLI script to run any `.dsl` file)
- `AST_PIPELINE.md` (AST architecture and module responsibilities)
- `CONSTRAINTS.md` (all current parser/conversion/semantic constraints)
- `FLOW.md` (flow state machine design notes)
- `src/main/rascal/Syntax.rsc` (grammar)
- `src/main/rascal/Parser.rsc` (parse entry points + structural and semantic check helpers)
- `src/main/rascal/Model.rsc` (AST data types)
- `src/main/rascal/Model/Gameplay.rsc` (Gameplay data types)
- `src/main/rascal/Model/Rule.rsc` (Rule data types)
- `src/main/rascal/ToModel.rsc` (parse tree -> AST conversion)
- `src/main/rascal/Checks.rsc` (semantic validations on AST)
- `src/main/rascal/Rules.rsc` (rule evaluation on state and actions)
- `src/main/rascal/Gameplay.rsc` (game logic, move simulation, flow execution)
- `src/main/rascal/UI.rsc` (Salix web UI: board grid, action buttons, flow chart)
- `src/main/rascal/Display.rsc` (ASCII board display utility)
- `src/main/rascal/BoGSL.rsc` (entry point: `playBoGSL`, `playChess`, `playLine`, `main`)
- `example/basic.dsl`
- `example/chess.dsl` (chess-like demo)
- `example/line.dsl` (minimal single-player example)

## Build
Run from repository root:

```sh
mvn package
```

## Running a game

### CLI (primary)
```sh
./bogsl.sh example/chess.dsl
./bogsl.sh --port 8080 example/line.dsl
```

Opens a browser UI at `http://localhost:5555` (or the port specified with `--port`).
The script builds the Maven dependency classpath on first run (cached in `target/.classpath`).

### REPL / IDE
From a Rascal REPL (e.g. the VSCode extension):

```rascal
import BoGSL;
playChess();
playLine();
playBoGSL(|cwd:///example/basic.dsl|);
```

Each call returns a `UIApp` that the Rascal IDE renders as an interactive web view.

### Parse-tree inspection only
```rascal
import Parser;
parseGameFile(|cwd:///example/chess.dsl|);
```

`example/chess.dsl` and `example/line.dsl` are valid end-to-end examples.
`example/chess.dsl` is a chess-like demo (white/black turn loop, a `rules` block with three game-level Movement rules, movement-level inline rules on several pawn moves, and explicit per-player piece placement).
`example/line.dsl` is the minimal example: a single piece moving forward along a 1×5 board until it falls off.
`example/basic.dsl` uses older `rule: <ID>` syntax at the game and piece level; it is kept for reference but does not parse with the current grammar.

`parseGameFile` and `parseGame` both:
- trim input before parsing
- parse with start symbol `Game`
- enforce one `board`, one `chest`, one `players`, and one `flow`, with optional `actions` via `checkGame`

## UI

BoGSL includes a browser-based interactive UI built with [Salix](https://github.com/usethesource/salix).

The UI shows:
- **Board grid** – pieces are rendered in their current cells; cells and piece labels are highlighted on hover when a move targets that cell.
- **Action list** – buttons for every move currently available to the active player. Clicking a button executes that move (`doAction`) and advances the flow state (`advanceFlow("moved")`).
- **Continue button** – shown when no moves are available for the current player. Clicking it advances the flow state via `advanceFlow("noMoves")`.
- **Flow chart** – a live Mermaid diagram of the flow state machine, with the current state highlighted and the relevant outgoing transition highlighted on hover.

Key functions in `UI.rsc`:
- `startUI(game, state) → UIApp` – builds the Salix app (for IDE / REPL use).
- `serveUI(game, state, host)` – starts a standalone HTTP server (used by `bogsl.sh`).

## AST and semantic checks
BoGSL uses an AST layer to separate parsing from game semantics.
The parser builds a parse tree, then converts it to a `GameDef` model, and then runs semantic checks on that model.

AST flow:
- DSL source text
- parse tree (`Syntax.rsc`)
- AST model (`Model.rsc`, through `ToModel.rsc`)
- semantic validation (`Checks.rsc`)

Detailed module-by-module explanation:
- [AST pipeline details](AST_PIPELINE.md)
- [Current constraints list](CONSTRAINTS.md)
- [Flow machine design](FLOW.md)

From a Rascal REPL:

```rascal
import Parser;

g = parseGameModelFile(|cwd:///example/chess.dsl|);
errs = checkGameModelFile(|cwd:///example/chess.dsl|);
```

`g` is a `GameDef` AST value and `errs` is a list of semantic errors.
`checkGameModel*` assumes structural parsing already succeeded (same `checkGame` rules as `parseGame*`).

## DSL structure
The start symbol is `Game`.

### `Game` is composed of
- `game : { ... }`
- one or more comma-separated `GameProperty`
- each `GameProperty` is one of:
  - `board: Board`
  - `chest: Chest`
  - `actions: Actions`
  - `players: Players`
  - `flow: Flow`
  - `rule: <ID>` (game-wide rule)

Note:
- The grammar allows properties in any order.
- The parser checker enforces exactly one `board`, one `chest`, one `players`, and one `flow`.
- `actions` is optional (zero or one block allowed).

### `Board` is composed of
- `{ width: Integer, height: Integer }`

Example:
```dsl
board: {width: 8, height: 8}
```

### `Players` is composed of
- `[ PlayerDefinition, PlayerDefinition, ... ]`
- supports empty players block (`[]`) and optional trailing comma

Example:
```dsl
players: [
  id: alice,
  pieces: {
    aliceKing: {
      type king
      direction: south
      initialPosition: {x: 4, y: 0}
    }
  },
  id: bob,
  pieces: {
    bobKing: {
      type king
      direction: north
      initialPosition: {x: 4, y: 7}
    }
  }
]
```

### `PlayerDefinition` is composed of
- `id: <playerID>, pieces: PieceAssignments`

### `PieceAssignments` is composed of
- `{ <pieceID>: { type <pieceTypeID>, direction: FacingDirection, initialPosition: {x: Integer, y: Integer} }, ... }` (inside a player definition)
- assignment properties can be comma-separated or newline-separated
- `type` accepts both `type pawn` and `type: pawn`

Example:
```dsl
players: [
  id: white,
  pieces: {
    whitePawnA: {
      type pawn
      direction: south
      initialPosition: {x: 0, y: 1}
    },
    whiteKing: {
      type: king,
      direction: south,
      initialPosition: {x: 4, y: 0}
    }
  }
]
```

### `Chest` is composed of
- `[ Piece, Piece, ... ]`
- supports empty chest (`[]`) and optional trailing comma

### `Piece` is composed of
- `piece <ID>: { Properties... }`
- `Properties` are comma-separated and each property is:
  - `move Movement`
  - `rule: <ID>` (piece-wide rule)

Example:
```dsl
piece pawn: {
  rule: pawnForwardOnly,
  move fwd: {forward 1},
  move fwd2: {forward 2}
}
```

### `Movement` is composed of
- `<MoveID>: { Direction, Direction, ... }`
- can also be empty: `move none: {}`

### `Direction` options
- `forward <Integer>`
- `backward <Integer>`
- `left <Integer>`
- `right <Integer>`

### `FacingDirection` options
- `north`
- `south`
- `east`
- `west`

### `Actions` is composed of
- `[ Action, Action, ... ]`
- supports empty list (`[]`) and optional trailing comma

### `Action` is composed of
- `action: {ID: <ID>, move: <MoveID>}`
- `ID` must be an assigned piece ID from `players -> pieces` (not a piece type from `chest`)

Example:
```dsl
actions: [
  action: {ID: p1Pawn, move: fwd},
  action: {ID: p2Pawn, move: fwd}
]
```

### `Flow` is composed of
- `{ start: <playerID>, end: gameOver, machine: Machine }`
- runtime uses flow events:
  - `moved` when the current player has at least one available move and executes one
  - `noMoves` when the current player has no available move
- available move computation (`availableMoves`) currently checks:
  - move belongs to one of the current player's assigned pieces (using all moves defined by each piece type)
  - target position is inside board limits
  - any movement-level rule attached to the move is satisfied

### `Machine` is composed of
- `[ StateNode, StateNode, ... ]`

### `StateNode` is composed of
- `state <playerID | gameOver>: { StateTransition, StateTransition, ... }`
- transitions can be empty: `state gameOver: {}`

### `StateTransition` is composed of
- `<moved|noMoves> -> <playerID|gameOver>`

Example:
```dsl
flow: {
  start: p1,
  end: gameOver,
  machine: [
    state p1: {
      moved -> p2,
      noMoves -> gameOver
    },
    state p2: {
      moved -> p1,
      noMoves -> gameOver
    },
    state gameOver: {}
  ]
}
```

### `Rules` block (game-level rules)

Declared as a top-level `GameProperty`:
- `rules: { Rule, Rule, ... }`
- supports empty block (`rules: {}`) and optional trailing comma

### `Rule` is composed of
- `rule <RuleType> <ID> : <RuleParts>`
- `RuleType` is one of `Movement`, `StartTurn`, `EndTurn`
- `RuleParts` is a rule logic expression (see below)

Example:
```dsl
rules: {
  rule Movement captureOnMoveOver: move piece current -> other player piece any,
  rule Movement captureKing: move piece current -> location{piece id:wK},
  rule Movement promote: move piece current -> location{x: any, y: opposite boardedge}
}
```

### Movement-level inline rules

A rule can be attached directly to a move definition inside a `Piece`:
- `move <MoveID>: { ... } rule <RuleType> <ID> : <RuleParts>`

Example:
```dsl
piece pawn: {
  move advance1: {forward 1},
  move firstMove: {forward 2} rule Movement firstMovePawn : location{ piece current } == location{ piece current initial },
  move captureL: {left 1, forward 1} rule Movement captureL: move piece current -> location{ opponent piece any}
}
```

### `RuleParts` (rule logic expressions)

Supported expressions:
- `move piece current` — the moving piece
- `move piece any` — any piece
- `other player piece any` — any opponent piece
- `location{ x: <Int|any|boardedge|opposite boardedge>, y: <Int|any|boardedge|opposite boardedge> }` — absolute coordinate location
- `location{ piece current }` — current location of the moving piece
- `location{ piece current initial }` — initial location of the moving piece
- `location{ opponent piece any }` — location of any opponent piece
- `location{ piece id:<ID> }` — location of a specific named piece
- `<left> -> <right>` — movement from left location to right location
- `<left> == <right>` — equality comparison
- `<left> != <right>` — inequality comparison
- `<left> and <right>` / `<left> && <right>` — logical AND
- `<left> || <right>` — logical OR
- `not(<expr>)` / `!(<expr>)` — logical NOT
- `capture <ID>` — capture a piece by type ID

### `PieceRuleProperty` (piece-level rule reference)
- `rule: <ID>` inside a piece definition
- declares that the piece is subject to a named rule (defined in the `rules` block)

Note: the `rule: <ID>` piece-level reference syntax is defined in the grammar (`PieceRuleProperty`) and extracted by `ToModel.rsc`, but is not yet wired into `PieceProperty` in the current grammar; this feature is under development.

## Full example
```dsl
game: {
  players: [
    id: p1,
    pieces: {
      p1Pawn: {
        type pawn
        direction: south
        initialPosition: {x: 0, y: 1}
      },
      p1Horse: {
        type horse
        direction: east
        initialPosition: {x: 1, y: 0}
      }
    },
    id: p2,
    pieces: {
      p2Pawn: {
        type pawn
        direction: north
        initialPosition: {x: 0, y: 6}
      },
      p2Horse: {
        type horse
        direction: west
        initialPosition: {x: 1, y: 7}
      }
    }
  ],
  board: {width: 8, height: 8},
  chest: [
    piece pawn: {
      move fwd: {forward 1},
      move fwd2: {forward 2} rule Movement firstMoveOnly : location{ piece current } == location{ piece current initial }
    },
    piece horse: {
      move fwdR: {forward 2, right 1},
      move rightDown: {backward 1, right 2},
      move none: {}
    }
  ],
  actions: [
    action: {ID: p1Pawn, move: fwd},
    action: {ID: p1Horse, move: fwdR},
    action: {ID: p2Pawn, move: fwd},
    action: {ID: p2Horse, move: fwdR}
  ],
  flow: {
    start: p1,
    end: gameOver,
    machine: [
      state p1: {
        moved -> p2,
        noMoves -> gameOver
      },
      state p2: {
        moved -> p1,
        noMoves -> gameOver
      },
      state gameOver: {}
    ]
  },
  rules: {
    rule Movement captureOnMove: move piece current -> other player piece any
  }
}
```
