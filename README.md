# BoGSL
A grid-based board game specific language (DSL), created for the Software Language Engineering course at Vrije Universiteit Amsterdam (2026).

## Project layout
- `pom.xml`
- `META-INF/RASCAL.MF`
- `src/main/rascal/Syntax.rsc` (grammar)
- `src/main/rascal/Parser.rsc` (parse entry points + basic checks)
- `src/main/rascal/exampleGame.dsl`
- `src/main/rascal/exampleGame2.dsl`

## Build
Run from repository root:

```sh
mvn package
```

## Running examples
In a Rascal REPL:

```rascal
import Parser;
parseGameFile(|file:///Users/gbianchi/dev/BoGSL/src/main/rascal/exampleGame.dsl|);
parseGameFile(|file:///Users/gbianchi/dev/BoGSL/src/main/rascal/exampleGame2.dsl|);
```

## DSL structure
The start symbol is `Game`.

### `Game` is composed of
- `game : { ... }`
- one or more comma-separated `GameProperty`
- each `GameProperty` is one of:
  - `board: Board`
  - `chest: Chest`
  - `actions: Actions`

Note:
- The grammar allows properties in any order.
- The parser checker enforces exactly one `board`, one `chest`, and one `actions`.

### `Board` is composed of
- `{ width: Integer, height: Integer }`

Example:
```dsl
board: {width: 8, height: 8}
```

### `Chest` is composed of
- `{ Piece, Piece, ... }`
- supports empty chest (`{}`) and optional trailing comma

### `Piece` is composed of
- `piece <ID>: { Properties... }`
- `Properties` are comma-separated and each property is:
  - `direction: FacingDirection`
  - `move Movement`

Example:
```dsl
piece pawn: {
  direction: south,
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

## Full example
```dsl
game: {
  board: {width: 8, height: 8},
  chest: {
    piece pawn: {
      direction: south,
      move fwd: {forward 1},
      move fwd2: {forward 2}
    },
    piece horse: {
      direction: east,
      move fwdR: {forward 2, right 1},
      move rightDown: {backward 1, right 2},
      move none: {}
    }
  },
  actions: [
    action: {ID: pawn, move: fwd},
    action: {ID: horse, move: fwdR}
  ]
}
```
