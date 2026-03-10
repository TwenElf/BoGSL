# BoGSL
A grid-based board game specific language (DSL), created for the Software Language Engineering course at Vrije Universiteit Amsterdam (2026).

## Project layout
- `pom.xml`
- `META-INF/RASCAL.MF`
- `AST_PIPELINE.md` (AST architecture and module responsibilities)
- `src/main/rascal/Syntax.rsc` (grammar)
- `src/main/rascal/Parser.rsc` (parse entry points + structural and semantic check helpers)
- `src/main/rascal/Model.rsc` (AST data types)
- `src/main/rascal/ToModel.rsc` (parse tree -> AST conversion)
- `src/main/rascal/Checks.rsc` (semantic validations on AST)
- `src/main/rascal/exampleGame.dsl`
- `src/main/rascal/exampleGame2.dsl`
- `src/main/rascal/exampleGame3.dsl` (chess-like demo)

## Build
Run from repository root:

```sh
mvn package
```

## Running examples
In a Rascal REPL:

```rascal
import Parser;
parseGameFile(|cwd:///src/main/rascal/exampleGame3.dsl|);
```

`exampleGame2.dsl` and `exampleGame3.dsl` are valid end-to-end examples.
`exampleGame3.dsl` is a chess-like demo (white/black turn loop, one game rule, and one piece rule: `enPassant` on `pawn`).
`exampleGame.dsl` is currently intentionally incomplete for structural-check testing (it misses `board`), so `parseGameFile` throws `"No board defined"`.

`parseGameFile` and `parseGame` both:
- trim input before parsing
- parse with start symbol `Game`
- enforce one `board`, one `chest`, one `actions`, one `players`, and one `flow` via `checkGame`

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

From a Rascal REPL:

```rascal
import Parser;

g = parseGameModelFile(|cwd:///src/main/rascal/exampleGame3.dsl|);
errs = checkGameModelFile(|cwd:///src/main/rascal/exampleGame3.dsl|);
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
- The parser checker enforces exactly one `board`, one `chest`, one `actions`, one `players`, and one `flow`.

### `Board` is composed of
- `{ width: Integer, height: Integer }`

Example:
```dsl
board: {width: 8, height: 8}
```

### `Players` is composed of
- `[ <ID>, <ID>, ... ]`
- supports empty list (`[]`) and optional trailing comma

Example:
```dsl
players: [alice, bob]
```

### `Chest` is composed of
- `{ Piece, Piece, ... }`
- supports empty chest (`{}`) and optional trailing comma

### `Piece` is composed of
- `piece <ID>: { Properties... }`
- `Properties` are comma-separated and each property is:
  - `direction: FacingDirection`
  - `move Movement`
  - `rule: <ID>` (piece-wide rule)

Example:
```dsl
piece pawn: {
  direction: south,
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

Example:
```dsl
actions: [
  action: {ID: pawn, move: fwd},
  action: {ID: horse, move: fwdR}
]
```

### `Flow` is composed of
- `{ start: <ID>, end: <ID>, machine: Machine }`

### `Machine` is composed of
- `{ StateNode, StateNode, ... }`

### `StateNode` is composed of
- `state <ID>: { StateTransition, StateTransition, ... }`
- transitions can be empty: `state gameOver: {}`

### `StateTransition` is composed of
- `<eventID> -> <targetStateID>`

Example:
```dsl
flow: {
  start: playerTurn,
  end: gameOver,
  machine: {
    state playerTurn: {
      endTurn -> resolveTurn
    },
    state resolveTurn: {
      next -> playerTurn,
      checkmate -> gameOver
    },
    state gameOver: {}
  }
}
```

### `GameRuleProperty` is composed of
- `rule: <ID>`

### `PieceRuleProperty` is composed of
- `rule: <ID>`

Examples:
```dsl
rule: boardBounds
rule: oneActionPerTurn
```

```dsl
piece pawn: {
  direction: south,
  rule: pawnForwardOnly,
  rule: pawnCaptureDiagonally,
  move advance1: {forward 1}
}
```

## Full example
```dsl
game: {
  players: [p1, p2],
  board: {width: 8, height: 8},
  chest: {
    piece pawn: {
      direction: south,
      rule: pawnForwardOnly,
      move fwd: {forward 1},
      move fwd2: {forward 2}
    },
    piece horse: {
      direction: east,
      rule: horseLMove,
      move fwdR: {forward 2, right 1},
      move rightDown: {backward 1, right 2},
      move none: {}
    }
  },
  actions: [
    action: {ID: pawn, move: fwd},
    action: {ID: horse, move: fwdR}
  ],
  flow: {
    start: playerTurn,
    end: gameOver,
    machine: {
      state playerTurn: {
        p1Move -> resolveTurn,
        p2Move -> resolveTurn
      },
      state resolveTurn: {
        nextP1 -> playerTurn,
        nextP2 -> playerTurn,
        gameEnds -> gameOver
      },
      state gameOver: {}
    }
  },
  rule: mustMoveInBounds,
  rule: oneActionPerTurn
}
```
