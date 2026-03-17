# Game Flow Design

This document describes the current BoGSL flow machine and how it is wired to gameplay execution.

## Flow Model

Flow is a directed state machine:
- `start`: the current player state where execution begins
- `end`: terminal state, fixed to `gameOver`
- `machine`: explicit state declarations and transitions

A state declaration:
- has a unique state name
- has zero or more transitions (`state gameOver: {}` is the terminal state)

A transition:
- has an event label
- points to a target state
- syntax: `<event> -> <state>`

## Current DSL Shape

```dsl
flow: {
  start: white,
  end: gameOver,
  machine: [
    state white: {
      moved -> black,
      noMoves -> gameOver
    },
    state black: {
      moved -> white,
      noMoves -> gameOver
    },
    state gameOver: {}
  ]
}
```

Events currently supported by grammar:
- `moved`
- `noMoves`

## Runtime Wiring

Gameplay uses the flow machine directly (`Gameplay.rsc`):

- `availableMoves(game, state, playerId)` computes legal moves for that player from all moves defined by each of that player's assigned pieces.
- `doFlowTurn(state, game)` executes one turn:
  - if at least one move is available, execute one and emit `moved`
  - otherwise emit `noMoves`
  - advance to the transition target for that event
- `doFlowGameplay(game)` loops `doFlowTurn` until `end` is reached (`gameOver`).

Move legality currently checks:
- move belongs to one of the player's assigned pieces
- target position is inside board bounds

## Validation Rules

Structural checks:
- exactly one `flow` block is required in a game

Semantic checks (`Checks.rsc`):
- state names must be in `players ∪ {gameOver}`
- `start` must be a player id
- `end` must be `gameOver`
- no duplicate state names
- no duplicate transitions `(event, target)` inside one state
- no unknown transition targets
- no unknown start/end state references
- non-`gameOver` states must define exactly one `moved` transition and one `noMoves` transition
- `end` must be reachable from `start`
