module Gameplay

import Display;
import IO;
import List;
import Model::Gameplay;
import Model::Rule;
import Model;
import Rules;


// Create a new `PieceState` from a piece assignment and type definition.
PieceState newPieceState(PieceAssignmentDef assignment, PieceDef pieceType) {
  map[str, MoveDef] moves
    = (move.name: move | MoveDef move <- pieceType.moves);

  switch (assignment) {
    case pieceAssignmentDef(_, _, _, Facing direction, positionDef(int x, int y)):
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
      case pieceAssignmentDef(_, str pieceId, str typeId, _, _): {
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
  list[Step] steps = piece.moves[action.moveId].steps;
  for (Step step <- steps) {
    piece = doMove(piece, step);
  }
  state.pieces[action.pieceId] = piece;
  return state;
}

// Utility: all legal moves currently available for a player.
// A move is considered available if:
// - it belongs to one of the player's assigned pieces
// - the resulting target square is inside the board
list[AvailableMove] availableMoves(GameDef game, GameplayState state, str playerId) {
  map[str, str] ownerByPiece = (assignment.pieceId: assignment.playerId | PieceAssignmentDef assignment <- game.assignedPieces);

  list[AvailableMove] moves = [];
  for (pieceId <- state.pieces) {
    if (!(pieceId in ownerByPiece) || ownerByPiece[pieceId] != playerId) {
      continue;
    }

    PieceState piece = state.pieces[pieceId];
    for (moveId <- piece.moves) {
      PieceState after = simulateMove(piece, moveId);
      if (isInsideBoard(game.board, after.x, after.y)){
        switch (piece.moves[moveId]){
          case moveDef(str _, list[Step] _, RuleDef rule): {
            if (!checkSingleRule(game, state, rule ,actionDef(pieceId, moveId))) continue;}// if the rule evaluates false it should not show up.
        }
 
        moves += [availableMove(playerId, pieceId, moveId, after.x, after.y)];
      }
    }
  }

  return moves;
}

list[PieceAssignmentDef] getPlayerPieces(GameDef game, GameplayState state, str playerId) {
  map[str, str] ownerByPiece = (assignment.pieceId: assignment.playerId | PieceAssignmentDef assignment <- game.assignedPieces);
  list[PieceAssignmentDef] pieces = [];
  for (pieceId <- state.pieces) {
    if (!(pieceId in ownerByPiece) || ownerByPiece[pieceId] != playerId) {
      continue;
    }
    pieces = pieces + [pieceId];
  }
  return pieces;
}

private bool isPlayerState(GameDef game, str flowState) {
  for (playerId <- game.players) {
    if (playerId == flowState) {
      return true;
    }
  }
  return false;
}

// Utility: available moves for the current flow-state player.
// If the current flow state is not a player (for example, gameOver), no moves are available.
list[AvailableMove] currentPlayerAvailableMoves(GameDef game, GameplayState state) {
  if (!isPlayerState(game, state.flowState)) {
    return [];
  }

  return availableMoves(game, state, state.flowState);
}

private PieceState simulateMove(PieceState piece, str moveId) {
  PieceState result = piece;
  for (step <- piece.moves[moveId].steps) {
    result = doMove(result, step);
  }
  return result;
}

private bool isInsideBoard(BoardDef board, int x, int y) {
  return x >= 0 && x < board.width && y >= 0 && y < board.height;
}

private StateDef findFlowState(FlowDef flow, str stateId) {
  for (state <- flow.states) {
    if (state.name == stateId) {
      return state;
    }
  }
  throw "Unknown flow state at runtime: <stateId>";
}

str advanceFlow(FlowDef flow, str currentState, str event) {
  StateDef state = findFlowState(flow, currentState);
  list[TransitionDef] matching = [t | t <- state.transitions, t.event == event];

  if (size(matching) == 1) {
    return matching[0].toState;
  }
  if (size(matching) == 0) {
    throw "No flow transition from <currentState> for event <event>";
  }
  throw "Ambiguous flow transitions from <currentState> for event <event>";
}

// Execute one turn for the current player state and advance the flow state.
GameplayState doFlowTurn(GameplayState state, GameDef game) {
  str currentPlayer = state.flowState;
  if (currentPlayer == game.flow.endState) {
    return state;
  }

  list[AvailableMove] moves = currentPlayerAvailableMoves(game, state);
  str event = "noMoves";

  if (size(moves) > 0) {
    AvailableMove chosen = moves[0];
    ActionDef action = actionDef(chosen.pieceId, chosen.moveId);
    bool valid = checkRules(game, state, action);
    state = doAction(state, game, action);
    event = "moved";
  }

  state.flowState = advanceFlow(game.flow, currentPlayer, event);
  return state;
}

// Execute gameplay by following the flow state machine until end is reached.
GameplayState doFlowGameplay(GameDef game) {
  GameplayState state = newGameplayState(game);
  int maxTurns = 1000;
  int turns = 0;

  while (state.flowState != game.flow.endState) {
    turns += 1;
    if (turns > maxTurns) {
      throw "Flow did not reach end state within <maxTurns> turns";
    }
    state = doFlowTurn(state, game);
  }

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
    bool valid = checkRules(game, state, action);
    state = doAction(state, game, action);
  }
  return state;
}
