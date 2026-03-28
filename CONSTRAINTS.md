# Game File Constraints

This document lists the validations currently applied to a BoGSL game file.

Validation pipeline (from `Parser.parseCheckGameModelFile`):
1. Parse source text with grammar (`Syntax.rsc`).
2. Run structural block checks (`Parser.checkGame`).
3. Convert parse tree to AST (`ToModel.rsc`) with conversion-time guards.
4. Run semantic checks on AST (`Checks.checkSemantics`).
5. Throw if semantic errors are not empty.

## 1. Grammar/Syntax Checks

The file must parse as `Game` in `Syntax.rsc`. If syntax is invalid, parsing fails before any semantic check.

## 2. Structural Top-Level Checks (`Parser.rsc`)

Required blocks (exactly one each):
- `chest`
- `board`
- `players`
- `flow`

Failure messages include:
- `No chest defined` / `Multiple chests defined`
- `No board defined` / `Multiple boards defined`
- `No players defined` / `Multiple players blocks defined`
- `No flow defined` / `Multiple flows defined`

Optional block:
- `actions` may be omitted; when using the browser UI, moves are selected interactively rather than declared upfront.
- if present more than once: `Multiple actions defined`

## 3. Conversion-Time Consistency Checks (`ToModel.rsc`)

These checks throw during parse-tree -> AST mapping:

- Required subtrees exist (`Board`, `Chest`, `Players`, `Flow`).
- `Actions` subtree is optional; missing `actions` maps to an empty action list.
- Board must provide exactly two integers: `width` and `height`.
- Each player definition must provide:
  - a player `id` property (`id: <name>`)
  - a `pieces` block
- Each piece assignment must provide:
  - a piece identifier
  - exactly one `type`
  - exactly one `direction`
  - exactly one `initialPosition`
- `initialPosition` must define exactly two integers (`x`, `y`).
- Flow must define both `start` and `end`.
- Every flow state must have a name.
- Every transition must define both event and target.
- Flow transition events are restricted by grammar to `moved` or `noMoves`.
- Every piece definition must have a piece identifier.
- Every move must have a move identifier.
- Every step direction must include exactly one amount.
- Direction/facing keywords must be known (`forward/backward/left/right`, `north/south/east/west`).
- Every action must define both piece ID and move ID.
- Every game rule and piece rule must define a rule ID.
- Every rule must have a known `RuleType` (`Movement`, `StartTurn`, or `EndTurn`); an unknown type throws a conversion error.
- Movement-level inline rules (attached to a move definition) follow the same `rule <RuleType> <ID> : <RuleParts>` form.

## 4. Semantic Checks (`Checks.rsc`)

### Players
- `MissingPlayers`: players block defines no players.
- `DuplicatePlayer(playerId)`: duplicate player ID.

### Piece Types (`chest` block)
- `DuplicatePiece(pieceTypeId)`: duplicate piece type ID.
- `DuplicateMove(pieceTypeId, moveId)`: duplicate move ID inside one piece type.

### Piece Assignments (`players -> pieces`)
- `DuplicateAssignedPiece(pieceId)`: duplicate assigned piece ID.
- `UnknownAssignedPiecePlayer(pieceId, playerId)`: assignment references unknown player ID.
- `UnknownAssignedPieceType(pieceId, typeId)`: assignment references unknown piece type.
- `DuplicateAssignedPiecePosition(pieceId, x, y)`: two assigned pieces share one initial square.
- `AssignedPieceOutOfBounds(pieceId, x, y, width, height)`: initial position outside board:
  - `x < 0 || x >= width || y < 0 || y >= height`

### Actions
- `UnknownActionPiece(pieceId)`: action references unknown assigned piece.
- `UnknownActionMove(pieceId, moveId)`: move is not defined for the assigned piece's type.

### Flow Machine
- `DuplicateFlowState(stateId)`: duplicate state ID.
- `InvalidFlowStateActor(stateId)`: state name is not a declared player and not `gameOver`.
- `InvalidFlowStartPlayer(stateId)`: `start` is not a declared player.
- `InvalidFlowEndState(stateId)`: `end` is not exactly `gameOver`.
- `AmbiguousFlowEventTransition(fromState, event)`: one state defines multiple transitions for the same event.
- `MissingFlowEventTransition(fromState, event)`: non-`gameOver` state is missing required `moved` or `noMoves`.
- `DuplicateFlowTransition(fromState, event, toState)`: duplicate edge in one state.
- `UnknownFlowStart(stateId)`: start state not declared.
- `UnknownFlowEnd(stateId)`: end state not declared.
- `UnknownFlowTransitionTarget(fromState, toState)`: transition target not declared.
- `UnreachableFlowEnd(startState, endState)`: end cannot be reached from start.

### Rules
- `DuplicateGameRule(ruleId)`: duplicate rule ID across all non-piece rules (`moveRuleDef`, `startTurnRuleDef`, `endTurnRuleDef`, `gameRuleDef`).
- `DuplicatePieceRule(pieceId, ruleId)`: duplicate piece-level rule reference ID for one piece type.
- `UnknownPieceRulePiece(pieceId, ruleId)`: piece-level rule reference targets an unknown piece type.

## 5. Final Failure Condition

`parseCheckGameModelFile` throws:
- `Errors in game file <errors>`

when any semantic errors are found.
