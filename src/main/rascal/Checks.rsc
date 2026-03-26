module Checks

import List;
import Map;
import Model;
import Syntax;
import Set;
import util::Maybe;
import ParseTree;

data SemanticError
  = DuplicatePiece(str pieceTypeId)
  | DuplicateMove(str pieceTypeId, str moveId)
  | DuplicateAssignedPiece(str pieceId)
  | UnknownAssignedPiecePlayer(str pieceId, str playerId)
  | UnknownAssignedPieceType(str pieceId, str typeId)
  | DuplicateAssignedPiecePosition(str pieceId, int x, int y)
  | AssignedPieceOutOfBounds(str pieceId, int x, int y, int width, int height)
  | MissingPlayers()
  | DuplicatePlayer(str playerId)
  | UnknownActionPiece(str pieceId)
  | UnknownActionMove(str pieceId, str moveId)
  | DuplicateFlowState(str stateId)
  | InvalidFlowStateActor(str stateId)
  | InvalidFlowStartPlayer(str stateId)
  | InvalidFlowEndState(str stateId)
  | AmbiguousFlowEventTransition(str fromState, str event)
  | MissingFlowEventTransition(str fromState, str event)
  | DuplicateFlowTransition(str fromState, str event, str toState)
  | UnknownFlowStart(str stateId)
  | UnknownFlowEnd(str stateId)
  | UnknownFlowTransitionTarget(str fromState, str toState)
  | UnreachableFlowEnd(str startState, str endState)
  | DuplicateGameRule(str ruleId)
  | DuplicatePieceRule(str pieceId, str ruleId)
  | UnknownPieceRulePiece(str pieceId, str ruleId)
  ;

alias SemanticErrorAt = tuple[SemanticError, Maybe[loc]];

private Maybe[loc] treeToLoc(Maybe[Tree] maybeTree) {
  if (just(tree) := maybeTree) {
    return just(tree.src);
  } else {
    return nothing();
  }
}

list[SemanticErrorAt] checkSemantics(GameDef game) {
  list[SemanticErrorAt] errors = [];

  switch (game) {
    case gameDef(BoardDef board, list[PieceDef] pieces, list[PieceAssignmentDef] assignedPieces, list[ActionDef] actions, FlowDef flow, list[RuleDef] rules, list[str] players, Maybe[Game] tree, Maybe[Players] playersTree): {
      set[str] pieceTypeIds = {};
      map[str, set[str]] movesByType = ();
      set[str] assignedPieceIds = {};
      map[str, set[str]] movesByAssignedPiece = ();
      set[tuple[int, int]] occupiedPositions = {};

      int boardWidth = 0;
      int boardHeight = 0;
      switch (board) {
        case boardDef(int width, int height, Maybe[Board] tree): {
          boardWidth = width;
          boardHeight = height;
        }
      }

      if (size(players) == 0) {
        errors += [<MissingPlayers(), treeToLoc(tree)>];
      }

      set[str] playerIds = {};
      for (playerId <- players) {
        if (playerId in playerIds) {
          errors += [<DuplicatePlayer(playerId), treeToLoc(playerTree)>];
        } else {
          playerIds += {playerId};
        }
      }

      for (piece <- pieces) {
        switch (piece) {
          case pieceDef(str pieceTypeId, list[MoveDef] moves, Maybe[Piece] tree): {
            if (pieceTypeId in pieceTypeIds) {
              errors += [<DuplicatePiece(pieceTypeId), treeToLoc(tree)>];
            } else {
              pieceTypeIds += {pieceTypeId};
            }

            set[str] moveIds = {};
            for (move <- moves) {
              switch (move) {
                case moveDef(str moveId, _, Maybe[Movement] tree): {
                  if (moveId in moveIds) {
                    errors += [<DuplicateMove(pieceTypeId, moveId), treeToLoc(tree)>];
                  } else {
                    moveIds += {moveId};
                  }
                }
              }
            }

            movesByType[pieceTypeId] = moveIds;
          }
        }
      }

      for (assignment <- assignedPieces) {
        switch (assignment) {
          case pieceAssignmentDef(str playerId, str pieceId, str typeId, _, positionDef(int x, int y, _), Maybe[PieceAssignment] tree): {
            if (pieceId in assignedPieceIds) {
              errors += [<DuplicateAssignedPiece(pieceId), treeToLoc(tree)>];
            } else {
              assignedPieceIds += {pieceId};
            }

            if (!(playerId in playerIds)) {
              errors += [<UnknownAssignedPiecePlayer(pieceId, playerId), treeToLoc(tree)>];
            }

            if (!(typeId in pieceTypeIds)) {
              errors += [<UnknownAssignedPieceType(pieceId, typeId), treeToLoc(tree)>];
              movesByAssignedPiece[pieceId] = {};
            } else {
              movesByAssignedPiece[pieceId] = movesByType[typeId];
            }

            tuple[int, int] pos = <x, y>;
            if (pos in occupiedPositions) {
              errors += [<DuplicateAssignedPiecePosition(pieceId, x, y), treeToLoc(tree)>];
            } else {
              occupiedPositions += {pos};
            }

            if (x < 0 || x >= boardWidth || y < 0 || y >= boardHeight) {
              errors += [<AssignedPieceOutOfBounds(pieceId, x, y, boardWidth, boardHeight), treeToLoc(tree)>];
            }
          }
        }
      }

      for (action <- actions) {
        switch (action) {
          case actionDef(str pieceId, str moveId, Maybe[Action] tree): {
            if (!(pieceId in assignedPieceIds)) {
              errors += [<UnknownActionPiece(pieceId), treeToLoc(tree)>];
            } else if (!(moveId in movesByAssignedPiece[pieceId])) {
              errors += [<UnknownActionMove(pieceId, moveId), treeToLoc(tree)>];
            }
          }
        }
      }

      errors += checkFlowSemantics(flow, playerIds);
      errors += checkRuleSemantics(rules, pieceTypeIds);
    }
  }

  return errors;
}

private list[SemanticErrorAt] checkFlowSemantics(FlowDef flow, set[str] playerIds) {
  list[SemanticErrorAt] errors = [];

  switch (flow) {
    case flowDef(str startState, str endState, list[StateDef] states, Maybe[Flow] tree): {
      set[str] stateIds = {};
      set[str] validStateActors = playerIds + {"gameOver"};

      for (state <- states) {
        switch (state) {
          case stateDef(str stateId, _, Maybe[FlowState] tree): {
            if (stateId in stateIds) {
              errors += [<DuplicateFlowState(stateId), treeToLoc(tree)>];
            } else {
              stateIds += {stateId};
            }

            if (!(stateId in validStateActors)) {
              errors += [<InvalidFlowStateActor(stateId), treeToLoc(tree)>];
            }
          }
        }
      }

      if (!(startState in playerIds)) {
        errors += [<InvalidFlowStartPlayer(startState), treeToLoc(tree)>];
      }

      if (endState != "gameOver") {
        errors += [<InvalidFlowEndState(endState), treeToLoc(tree)>];
      }

      if (!(startState in stateIds)) {
        errors += [<UnknownFlowStart(startState), treeToLoc(tree)>];
      }

      if (!(endState in stateIds)) {
        errors += [<UnknownFlowEnd(endState), treeToLoc(tree)>];
      }

      for (state <- states) {
        switch (state) {
          case stateDef(str fromState, list[TransitionDef] transitions, Maybe[FlowState] tree): {
            set[tuple[str, str]] seenTransitions = {};
            map[str, int] eventCounts = ();
            for (transition <- transitions) {
              switch (transition) {
                case transitionDef(str event, str toState, Maybe[StateTransition] tree): {
                  tuple[str, str] edge = <event, toState>;
                  if (edge in seenTransitions) {
                    errors += [<DuplicateFlowTransition(fromState, event, toState), treeToLoc(tree)>];
                  } else {
                    seenTransitions += {edge};
                  }

                  if (!(toState in stateIds)) {
                    errors += [<UnknownFlowTransitionTarget(fromState, toState), treeToLoc(tree)>];
                  }

                  if (!(event in eventCounts)) {
                    eventCounts[event] = 0;
                  }
                  eventCounts[event] += 1;
                }
              }
            }

            if (fromState != "gameOver") {
              if (!("moved" in eventCounts)) {
                errors += [<MissingFlowEventTransition(fromState, "moved"), treeToLoc(tree)>];
              }
              if (!("noMoves" in eventCounts)) {
                errors += [<MissingFlowEventTransition(fromState, "noMoves"), treeToLoc(tree)>];
              }
            }

            for (event <- eventCounts) {
              if (eventCounts[event] > 1) {
                errors += [<AmbiguousFlowEventTransition(fromState, event), treeToLoc(tree)>];
              }
            }
          }
        }
      }

      if (!(startState in stateIds) || !(endState in stateIds)) {
        return errors;
      }

      set[str] reachable = {startState};
      bool changed = true;
      while (changed) {
        changed = false;
        for (state <- states) {
          switch (state) {
            case stateDef(str fromState, list[TransitionDef] transitions, Maybe[FlowState] tree): {
              if (!(fromState in reachable)) {
                continue;
              }
              for (transition <- transitions) {
                switch (transition) {
                  case transitionDef(_, str toState, Maybe[StateTransition] tree): {
                    if (!(toState in reachable) && toState in stateIds) {
                      reachable += {toState};
                      changed = true;
                    }
                  }
                }
              }
            }
          }
        }
      }

      if (!(endState in reachable)) {
        errors += [<UnreachableFlowEnd(startState, endState), treeToLoc(tree)>];
      }
    }
  }

  return errors;
}

private list[SemanticErrorAt] checkRuleSemantics(list[RuleDef] rules, set[str] pieceTypeIds) {
  list[SemanticErrorAt] errors = [];
  set[str] gameRuleIds = {};
  set[tuple[str, str]] pieceRuleIds = {};

  for (rule <- rules) {
    switch (rule) {
      case gameRuleDef(str ruleId, Maybe[GameRuleProperty] tree): {
        if (ruleId in gameRuleIds) {
          errors += [<DuplicateGameRule(ruleId), treeToLoc(tree)>];
        } else {
          gameRuleIds += {ruleId};
        }
      }

      case pieceRuleDef(str pieceId, str ruleId, Maybe[PieceRuleProperty] tree): {
        if (!(pieceId in pieceTypeIds)) {
          errors += [<UnknownPieceRulePiece(pieceId, ruleId), treeToLoc(tree)>];
        }

        tuple[str, str] key = <pieceId, ruleId>;
        if (key in pieceRuleIds) {
          errors += [<DuplicatePieceRule(pieceId, ruleId), treeToLoc(tree)>];
        } else {
          pieceRuleIds += {key};
        }
      }
    }
  }

  return errors;
}
