module Checks

import List;
import Map;
import Model;
import Set;

data SemanticError
  = DuplicatePiece(str pieceId)
  | MissingPieceDirection(str pieceId)
  | MultiplePieceDirections(str pieceId, int count)
  | DuplicateMove(str pieceId, str moveId)
  | MissingPlayers()
  | DuplicatePlayer(str playerId)
  | UnknownActionPiece(str pieceId)
  | UnknownActionMove(str pieceId, str moveId)
  | DuplicateFlowState(str stateId)
  | DuplicateFlowTransition(str fromState, str event, str toState)
  | UnknownFlowStart(str stateId)
  | UnknownFlowEnd(str stateId)
  | UnknownFlowTransitionTarget(str fromState, str toState)
  | UnreachableFlowEnd(str startState, str endState)
  | DuplicateGameRule(str ruleId)
  | DuplicatePieceRule(str pieceId, str ruleId)
  | UnknownPieceRulePiece(str pieceId, str ruleId)
  ;

list[SemanticError] checkSemantics(GameDef game) {
  list[SemanticError] errors = [];

  switch (game) {
    case gameDef(_, list[PieceDef] pieces, list[ActionDef] actions, FlowDef flow, list[RuleDef] rules, list[str] players): {
      set[str] pieceIds = {};
      map[str, set[str]] movesByPiece = ();
      set[str] playerIds = {};

      if (size(players) == 0) {
        errors += [MissingPlayers()];
      }

      for (playerId <- players) {
        if (playerId in playerIds) {
          errors += [DuplicatePlayer(playerId)];
        } else {
          playerIds += {playerId};
        }
      }

      for (piece <- pieces) {
        switch (piece) {
          case pieceDef(str pieceId, list[Facing] directions, list[MoveDef] moves): {
            if (pieceId in pieceIds) {
              errors += [DuplicatePiece(pieceId)];
            } else {
              pieceIds += {pieceId};
            }

            if (size(directions) == 0) {
              errors += [MissingPieceDirection(pieceId)];
            } else if (size(directions) > 1) {
              errors += [MultiplePieceDirections(pieceId, size(directions))];
            }

            set[str] moveIds = {};
            for (move <- moves) {
              switch (move) {
                case moveDef(str moveId, _): {
                  if (moveId in moveIds) {
                    errors += [DuplicateMove(pieceId, moveId)];
                  } else {
                    moveIds += {moveId};
                  }
                }
              }
            }

            movesByPiece[pieceId] = moveIds;
          }
        }
      }

      for (action <- actions) {
        switch (action) {
          case actionDef(str pieceId, str moveId): {
            if (!(pieceId in pieceIds)) {
              errors += [UnknownActionPiece(pieceId)];
            } else if (!(moveId in movesByPiece[pieceId])) {
              errors += [UnknownActionMove(pieceId, moveId)];
            }
          }
        }
      }

      errors += checkFlowSemantics(flow);
      errors += checkRuleSemantics(rules, pieceIds);
    }
  }

  return errors;
}

private list[SemanticError] checkFlowSemantics(FlowDef flow) {
  list[SemanticError] errors = [];

  switch (flow) {
    case flowDef(str startState, str endState, list[StateDef] states): {
      set[str] stateIds = {};

      for (state <- states) {
        switch (state) {
          case stateDef(str stateId, _): {
            if (stateId in stateIds) {
              errors += [DuplicateFlowState(stateId)];
            } else {
              stateIds += {stateId};
            }
          }
        }
      }

      if (!(startState in stateIds)) {
        errors += [UnknownFlowStart(startState)];
      }

      if (!(endState in stateIds)) {
        errors += [UnknownFlowEnd(endState)];
      }

      for (state <- states) {
        switch (state) {
          case stateDef(str fromState, list[TransitionDef] transitions): {
            set[tuple[str, str]] seenTransitions = {};
            for (transition <- transitions) {
              switch (transition) {
                case transitionDef(str event, str toState): {
                  tuple[str, str] edge = <event, toState>;
                  if (edge in seenTransitions) {
                    errors += [DuplicateFlowTransition(fromState, event, toState)];
                  } else {
                    seenTransitions += {edge};
                  }

                  if (!(toState in stateIds)) {
                    errors += [UnknownFlowTransitionTarget(fromState, toState)];
                  }
                }
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
            case stateDef(str fromState, list[TransitionDef] transitions): {
              if (!(fromState in reachable)) {
                continue;
              }
              for (transition <- transitions) {
                switch (transition) {
                  case transitionDef(_, str toState): {
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
        errors += [UnreachableFlowEnd(startState, endState)];
      }
    }
  }

  return errors;
}

private list[SemanticError] checkRuleSemantics(list[RuleDef] rules, set[str] pieceIds) {
  list[SemanticError] errors = [];
  set[str] gameRuleIds = {};
  set[tuple[str, str]] pieceRuleIds = {};

  for (rule <- rules) {
    switch (rule) {
      case gameRuleDef(str ruleId): {
        if (ruleId in gameRuleIds) {
          errors += [DuplicateGameRule(ruleId)];
        } else {
          gameRuleIds += {ruleId};
        }
      }

      case pieceRuleDef(str pieceId, str ruleId): {
        if (!(pieceId in pieceIds)) {
          errors += [UnknownPieceRulePiece(pieceId, ruleId)];
        }

        tuple[str, str] key = <pieceId, ruleId>;
        if (key in pieceRuleIds) {
          errors += [DuplicatePieceRule(pieceId, ruleId)];
        } else {
          pieceRuleIds += {key};
        }
      }
    }
  }

  return errors;
}
