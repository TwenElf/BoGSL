module ToModel

import util::Maybe;
import Model;
import ParseTree;
import String;
import Syntax;

GameDef toModel(Game gameTree) {
  Board boardTree = firstBoard(gameTree);
  Chest chestTree = firstChest(gameTree);
  Players playersTree = firstPlayers(gameTree);
  Flow flowTree = firstFlow(gameTree);

  FlowDef flow = toFlowDef(flowTree);
  list[RuleDef] rules = toGameRuleDefs(gameTree) + toPieceRuleDefs(chestTree);
  list[str] players = toPlayers(playersTree);
  list[PieceAssignmentDef] assignedPieces = toPieceAssignments(playersTree);

  return gameDef(
    toBoardDef(boardTree),
    toPieceDefs(chestTree),
    assignedPieces,
    toOptionalActionDefs(gameTree),
    flow,
    rules,
    players,
    tree = just(gameTree),
    playersTree = just(playersTree)
  );
}

private Board firstBoard(Game gameTree) {
  list[Board] boards = [];
  visit(gameTree) {
    case Board boardTree: boards += [boardTree];
  }

  if (size(boards) == 0) {
    throw "Game has no board";
  }

  return boards[0];
}

private Chest firstChest(Game gameTree) {
  list[Chest] chests = [];
  visit(gameTree) {
    case Chest chestTree: chests += [chestTree];
  }

  if (size(chests) == 0) {
    throw "Game has no chest";
  }

  return chests[0];
}

private list[ActionDef] toOptionalActionDefs(Game gameTree) {
  list[Actions] allActions = [];
  visit(gameTree) {
    case Actions actionsTree: allActions += [actionsTree];
  }

  if (size(allActions) == 0) {
    return [];
  }

  if (size(allActions) > 1) {
    throw "Game has multiple actions blocks";
  }

  return toActionDefs(allActions[0]);
}

private Players firstPlayers(Game gameTree) {
  list[Players] allPlayers = [];
  visit(gameTree) {
    case Players playersTree: allPlayers += [playersTree];
  }

  if (size(allPlayers) == 0) {
    throw "Game has no players";
  }

  return allPlayers[0];
}

private Flow firstFlow(Game gameTree) {
  list[Flow] flows = [];
  visit(gameTree) {
    case Flow flowTree: flows += [flowTree];
  }

  if (size(flows) == 0) {
    throw "Game has no flow";
  }

  return flows[0];
}

BoardDef toBoardDef(Board boardTree) {
  list[int] values = [];
  visit(boardTree) {
    case Integer valueTree: values += [toInt(unparse(valueTree))];
  }

  if (size(values) != 2) {
    throw "Board must define width and height";
  }

  return boardDef(values[0], values[1], tree = just(boardTree));
}

list[str] toPlayers(Players playersTree) {
  list[str] players = [];
  for (definition <- playerDefinitions(playersTree)) {
    players += [toPlayerId(definition)];
  }
  return players;
}

private list[PlayerDefinition] playerDefinitions(Players playersTree) {
  list[PlayerDefinition] definitions = [];
  visit(playersTree) {
    case PlayerDefinition definitionTree: definitions += [definitionTree];
  }
  return definitions;
}

private str toPlayerId(PlayerDefinition playerDefinitionTree) {
  str playerId = "";
  visit(playerDefinitionTree) {
    case PlayerName playerTree: if (playerId == "") playerId = trim(unparse(playerTree));
  }
  if (playerId == "") {
    throw "Player definition must define an id";
  }
  return playerId;
}

list[PieceAssignmentDef] toPieceAssignments(Players playersTree) {
  list[PieceAssignmentDef] assignments = [];
  for (playerDefinitionTree <- playerDefinitions(playersTree)) {
    assignments += toPieceAssignments(playerDefinitionTree);
  }
  return assignments;
}

private list[PieceAssignmentDef] toPieceAssignments(PlayerDefinition playerDefinitionTree) {
  str playerId = toPlayerId(playerDefinitionTree);
  list[PieceAssignmentDef] assignments = [];
  visit(playerDefinitionTree) {
    case PieceAssignment pieceAssignmentTree: assignments += [toPieceAssignmentDef(playerId, pieceAssignmentTree)];
  }
  return assignments;
}

PieceAssignmentDef toPieceAssignmentDef(str playerId, PieceAssignment pieceAssignmentTree) {
  str pieceId = "";
  str typeId = "";
  list[Facing] directions = [];
  list[PositionDef] positions = [];

  visit(pieceAssignmentTree) {
    case AssignedPiece pieceNameTree: if (pieceId == "") pieceId = trim(unparse(pieceNameTree));
    case AssignedPieceType typeTree: if (typeId == "") typeId = trim(unparse(typeTree));
    case FacingDirection directionTree: directions += [toFacing(directionTree)];
    case InitialPosition positionTree: positions += [toPositionDef(positionTree)];
  }

  if (pieceId == "") {
    throw "Piece assignment has no piece identifier";
  }
  if (typeId == "") {
    throw "Piece assignment <pieceId> must define exactly one type";
  }
  if (size(directions) != 1) {
    throw "Piece assignment <pieceId> must define exactly one direction";
  }
  if (size(positions) != 1) {
    throw "Piece assignment <pieceId> must define exactly one initialPosition";
  }

  return pieceAssignmentDef(playerId, pieceId, typeId, directions[0], positions[0], tree = just(pieceAssignmentTree));
}

PositionDef toPositionDef(InitialPosition positionTree) {
  list[int] coords = [];
  visit(positionTree) {
    case Integer valueTree: coords += [toInt(unparse(valueTree))];
  }

  if (size(coords) != 2) {
    throw "initialPosition must define x and y";
  }

  return positionDef(coords[0], coords[1], tree = just(positionTree));
}

FlowDef toFlowDef(Flow flowTree) {
  str startState = "";
  str endState = "";
  list[StateDef] states = [];

  visit(flowTree) {
    case StartState startTree: if (startState == "") startState = trim(unparse(startTree));
    case EndState endTree: if (endState == "") endState = trim(unparse(endTree));
    case FlowState stateTree: states += [toStateDef(stateTree)];
  }

  if (startState == "" || endState == "") {
    throw "Flow must define both start and end states";
  }

  return flowDef(startState, endState, states, tree = just(flowTree));
}

StateDef toStateDef(FlowState stateTree) {
  str stateName = "";
  list[TransitionDef] transitions = [];

  visit(stateTree) {
    case StateName nameTree: if (stateName == "") stateName = trim(unparse(nameTree));
    case StateTransition transitionTree: transitions += [toTransitionDef(transitionTree)];
  }

  if (stateName == "") {
    throw "Flow state must define a name";
  }

  return stateDef(stateName, transitions, tree = just(stateTree));
}

TransitionDef toTransitionDef(StateTransition transitionTree) {
  str event = "";
  str toState = "";

  visit(transitionTree) {
    case TransitionEvent eventTree: if (event == "") event = trim(unparse(eventTree));
    case TransitionTarget targetTree: if (toState == "") toState = trim(unparse(targetTree));
  }

  if (event == "" || toState == "") {
    throw "Flow transition must define event and target state";
  }

  return transitionDef(event, toState, tree = just(transitionTree));
}

list[PieceDef] toPieceDefs(Chest chestTree) {
  list[PieceDef] pieces = [];
  visit(chestTree) {
    case Piece pieceTree: pieces += [toPieceDef(pieceTree)];
  }
  return pieces;
}

list[RuleDef] toPieceRuleDefs(Chest chestTree) {
  list[RuleDef] rules = [];
  visit(chestTree) {
    case Piece pieceTree: rules += toPieceRuleDefs(pieceTree);
  }
  return rules;
}

list[RuleDef] toPieceRuleDefs(Piece pieceTree) {
  str pieceId = "";
  list[PieceRuleProperty] ruleTrees = [];

  visit(pieceTree) {
    case ID idTree: if (pieceId == "") pieceId = trim(unparse(idTree));
    case PieceRuleProperty ruleTree: ruleTrees += [ruleTree];
  }

  if (pieceId == "") {
    throw "Piece has no identifier";
  }

  return [pieceRuleDef(pieceId, toRuleId(ruleTree), pieceRuleTree = just(ruleTree)) | ruleTree <- ruleTrees];
}

PieceDef toPieceDef(Piece pieceTree) {
  str pieceName = "";
  list[MoveDef] moves = [];

  visit(pieceTree) {
    case ID nameTree: if (pieceName == "") pieceName = trim(unparse(nameTree));
    case Movement movementTree: moves += [toMoveDef(movementTree)];
  }

  if (pieceName == "") {
    throw "Piece has no identifier";
  }

  return pieceDef(pieceName, moves, tree = just(pieceTree));
}

Facing toFacing(FacingDirection directionTree) {
  str directionText = trim(unparse(directionTree));
  switch (directionText) {
    case "north": return northFacing(tree = just(directionTree));
    case "south": return southFacing(tree = just(directionTree));
    case "east": return eastFacing(tree = just(directionTree));
    case "west": return westFacing(tree = just(directionTree));
    default: throw "Unknown facing direction: <directionText>";
  }
}

MoveDef toMoveDef(Movement movementTree) {
  str moveName = "";
  list[Step] steps = [];

  visit(movementTree) {
    case MoveID moveIdTree: if (moveName == "") moveName = unparse(moveIdTree);
    case Direction directionTree: steps += [toStep(directionTree)];
  }

  if (moveName == "") {
    throw "Move has no identifier";
  }

  return moveDef(moveName, steps, tree = just(movementTree));
}

Step toStep(Direction directionTree) {
  str directionText = trim(unparse(directionTree));
  list[int] amounts = [];

  visit(directionTree) {
    case Integer amountTree: amounts += [toInt(unparse(amountTree))];
  }

  if (size(amounts) != 1) {
    throw "Direction should contain exactly one amount";
  }

  int amount = amounts[0];

  if (startsWith(directionText, "forward")) return forwardStep(amount, tree = just(directionTree));
  if (startsWith(directionText, "backward")) return backwardStep(amount, tree = just(directionTree));
  if (startsWith(directionText, "left")) return leftStep(amount, tree = just(directionTree));
  if (startsWith(directionText, "right")) return rightStep(amount, tree = just(directionTree));

  throw "Unknown direction: <directionText>";
}

list[ActionDef] toActionDefs(Actions actionsTree) {
  list[ActionDef] actions = [];
  visit(actionsTree) {
    case Action actionTree: actions += [toActionDef(actionTree)];
  }
  return actions;
}

ActionDef toActionDef(Action actionTree) {
  str pieceId = "";
  str moveId = "";

  visit(actionTree) {
    case ID idTree: if (pieceId == "") pieceId = unparse(idTree);
    case MoveID moveTree: if (moveId == "") moveId = unparse(moveTree);
  }

  if (pieceId == "" || moveId == "") {
    throw "Action must define both piece ID and move ID";
  }

  return actionDef(pieceId, moveId, tree = just(actionTree));
}

list[RuleDef] toGameRuleDefs(Game gameTree) {
  list[RuleDef] rules = [];
  visit(gameTree) {
    case GameRuleProperty ruleTree: rules += [gameRuleDef(toRuleId(ruleTree), gameRuleTree = just(ruleTree))];
  }
  return rules;
}

str toRuleId(GameRuleProperty gameRuleTree) {
  str ruleId = "";
  visit(gameRuleTree) {
    case RuleName ruleNameTree: if (ruleId == "") ruleId = trim(unparse(ruleNameTree));
  }
  if (ruleId == "") {
    throw "Game rule must define a rule ID";
  }
  return ruleId;
}

str toRuleId(PieceRuleProperty pieceRuleTree) {
  str ruleId = "";
  visit(pieceRuleTree) {
    case RuleName ruleNameTree: if (ruleId == "") ruleId = trim(unparse(ruleNameTree));
  }
  if (ruleId == "") {
    throw "Piece rule must define a rule ID";
  }
  return ruleId;
}
