# Game Flow Design

This document defines the BoGSL game-flow state machine in the node/edge style:
- a machine is a set of nodes (`state`)
- each node has zero or more outgoing transitions
- each transition is written as `event -> targetNode`

## Core Model

Flow is a directed graph:
- `start`: entry node
- `end`: terminal node
- `machine`: node declarations

A node declaration:
- has a unique node name
- contains zero or more outgoing transitions

A transition:
- has an event label (`event`)
- points to a target node (`targetNode`)
- syntax: `event -> targetNode`

This naturally supports:
- branching (one node to many targets)
- merging (many nodes to one target)
- self-loops (`tick -> sameNode`)
- turn loops (for example white turn -> black turn -> white turn)

## DSL Syntax

```dsl
flow: {
  start: setup,
  end: gameOver,
  machine: {
    state setup: {
      startGame -> playerTurnWhite
    },
    state playerTurnWhite: {
      move -> resolveWhite,
      resign -> gameOver
    },
    state resolveWhite: {
      next -> playerTurnBlack,
      checkmate -> gameOver
    },
    state playerTurnBlack: {
      move -> resolveBlack,
      resign -> gameOver
    },
    state resolveBlack: {
      next -> playerTurnWhite,
      checkmate -> gameOver
    },
    state gameOver: {}
  }
}
```

## AST Representation

- `FlowDef = flowDef(startState, endState, states)`
- `StateDef = stateDef(name, transitions)`
- `TransitionDef = transitionDef(event, toState)`

## Current Validation

Structural checks:
- exactly one `flow` block in a game

Semantic checks:
- no duplicate state names
- no duplicate transitions inside one state with the same `(event, target)` pair
- transition targets must refer to declared states
- `start` and `end` must refer to declared states
- `end` must be reachable from `start`

## Notes on Player Order

Player order is modeled by your node topology and transition edges.
For example:
- `playerTurnWhite` node transitions to `playerTurnBlack`
- `playerTurnBlack` transitions back to `playerTurnWhite`
- either can transition to `gameOver` when a rule-trigger event occurs

Rule evaluation that triggers events is intentionally outside the flow checker and can be added in later execution logic.
