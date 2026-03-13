module Gameplay

import Model;
import IO;

data PieceState
  = pieceState(int x, int y, Facing facing, map[str, list[Step]] moves)
  ;

data GameplayState
  = gameplayState(str flowState, map[str, PieceState] pieces)
  ;

// Create a new `PieceState` from a piece assignment and type definition.
PieceState newPieceState(PieceAssignmentDef assignment, PieceDef pieceType) {
  map[str, list[Step]] moves
    = (move.name: move.steps | MoveDef move <- pieceType.moves);

  switch (assignment) {
    case pieceAssignmentDef(_, _, Facing direction, positionDef(int x, int y)):
      return pieceState(x, y, direction, moves);
  }

  throw "Invalid piece assignment";
}

// Create a new `GameplayState`
GameplayState newGameplayState(GameDef game) {
  str flowState = game.flow.startState;

  map[str, PieceDef] pieceTypes
    = (piece.name: piece | PieceDef piece <- game.pieces);

  map[str, PieceState] pieces = ();
  for (assignment <- game.assignedPieces) {
    switch (assignment) {
      case pieceAssignmentDef(str pieceId, str typeId, _, _): {
        if (!(typeId in pieceTypes)) {
          throw "Assigned piece <pieceId> references unknown type <typeId>";
        }
        pieces[pieceId] = newPieceState(assignment, pieceTypes[typeId]);
      }
    }
  }

  return gameplayState(flowState, pieces);
}

// Do one `ActionDef` and return the new `GameplayState`
GameplayState doAction(GameplayState state, GameDef game, ActionDef action) {
  PieceState piece = state.pieces[action.pieceId];
  list[Step] steps = piece.moves[action.moveId];
  for (Step step <- steps) {
    piece = doMove(piece, step);
  }
  state.pieces[action.pieceId] = piece;
  return state;
}

// Do one `Step` and return the new `PieceState`
PieceState doMove(PieceState piece, Step step) {
  switch (<piece.facing, step>) {
    case <northFacing(), forwardStep(amount)>: piece.y -= amount;
    case <southFacing(), forwardStep(amount)>: piece.y += amount;
    case <eastFacing(), forwardStep(amount)>: piece.x += amount;
    case <westFacing(), forwardStep(amount)>: piece.x -= amount;

    case <northFacing(), backwardStep(amount)>: piece.y += amount;
    case <southFacing(), backwardStep(amount)>: piece.y -= amount;
    case <eastFacing(), backwardStep(amount)>: piece.x -= amount;
    case <westFacing(), backwardStep(amount)>: piece.x += amount;

    case <northFacing(), leftStep(amount)>: piece.x -= amount;
    case <southFacing(), leftStep(amount)>: piece.x += amount;
    case <eastFacing(), leftStep(amount)>: piece.y += amount;
    case <westFacing(), leftStep(amount)>: piece.y -= amount;

    case <northFacing(), rightStep(amount)>: piece.x += amount;
    case <southFacing(), rightStep(amount)>: piece.x -= amount;
    case <eastFacing(), rightStep(amount)>: piece.y -= amount;
    case <westFacing(), rightStep(amount)>: piece.y += amount;
  }
  return piece;
}

// Do all actions in a `GameDef`
GameplayState doActions(GameDef game) {
  GameplayState state = newGameplayState(game);
  for (ActionDef action <- game.actions) {
    state = doAction(state, game, action);
  }
  return state;
}
