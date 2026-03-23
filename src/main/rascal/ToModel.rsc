module ToModel

import Model;
import Model::Rule;
import Model::Gameplay;
import ParseTree;
import String;
import Syntax;
import Rules;

import IO; // TODO: Remove later

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
    players
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

  return boardDef(values[0], values[1]);
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

  return pieceAssignmentDef(playerId, pieceId, typeId, directions[0], positions[0]);
}

PositionDef toPositionDef(InitialPosition positionTree) {
  list[int] coords = [];
  visit(positionTree) {
    case Integer valueTree: coords += [toInt(unparse(valueTree))];
  }

  if (size(coords) != 2) {
    throw "initialPosition must define x and y";
  }

  return positionDef(coords[0], coords[1]);
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

  return flowDef(startState, endState, states);
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

  return stateDef(stateName, transitions);
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

  return transitionDef(event, toState);
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
  list[str] ruleIds = [];

  visit(pieceTree) {
    case ID idTree: if (pieceId == "") pieceId = trim(unparse(idTree));
    case PieceRuleProperty ruleTree: ruleIds += [toRuleId(ruleTree)];
  }

  if (pieceId == "") {
    throw "Piece has no identifier";
  }

  return [pieceRuleDef(pieceId, ruleId) | ruleId <- ruleIds];
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

  return pieceDef(pieceName, moves);
}

Facing toFacing(FacingDirection directionTree) {
  str directionText = trim(unparse(directionTree));
  switch (directionText) {
    case "north": return northFacing();
    case "south": return southFacing();
    case "east": return eastFacing();
    case "west": return westFacing();
    default: throw "Unknown facing direction: <directionText>";
  }
}

MoveDef toMoveDef(Movement movementTree) {
  str moveName = "";
  list[Step] steps = [];
  list[RuleDef] rule = [];

  visit(movementTree) {
    case MoveID moveIdTree: if (moveName == "") moveName = unparse(moveIdTree);
    case Direction directionTree: steps += [toStep(directionTree)];
    case Rule ruleTree: rule += [toRuleDef(ruleTree)];
  }

  if (moveName == "") {
    throw "Move has no identifier";
  }
  if(rule != []) return moveDef(moveName, steps, rule[0]);
  return moveDef(moveName, steps);
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

  if (startsWith(directionText, "forward")) return forwardStep(amount);
  if (startsWith(directionText, "backward")) return backwardStep(amount);
  if (startsWith(directionText, "left")) return leftStep(amount);
  if (startsWith(directionText, "right")) return rightStep(amount);

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

  return actionDef(pieceId, moveId);
}

list[RuleDef] toGameRuleDefs(Game gameTree) {
  list[RuleDef] rules = [];
  visit(gameTree) {
    //case (Rule) `rule <RuleType rt> <RuleID id> : <RuleParts* parts>`: {rules += [gameRuleDef(toRuleId(id), toRuleLogic(parts))];}
    case Rule ruleTree: rules += [toRuleDef(ruleTree)];
  }
  return rules;
}


RuleDef toRuleDef(Rule gameRuleTree){
  visit(gameRuleTree){
    case (Rule) `rule <RuleType rt> <RuleID id> : <RuleParts parts>`: {
      switch(rt){
        case (RuleType) `Movement`: return moveRuleDef(toRuleId(id), toRuleLogic(parts));
        case (RuleType) `StartTurn`: return startTurnRuleDef(toRuleId(id), toRuleLogic(parts));
        case (RuleType) `EndTurn`: return endTurnRuleDef(toRuleId(id), toRuleLogic(parts));
      }
    }
  }
  throw "GameRule did not contain valid RuleType for tree \n <gameRuleTree>";
}

str toRuleId(Rule gameRuleTree) {
  str ruleId = "";
  visit(gameRuleTree) {
    case RuleID ruleNameTree: if (ruleId == "") ruleId = trim(unparse(ruleNameTree));
  }
  if (ruleId == "") {
    throw "Game rule must define a rule ID";
  }
  return ruleId;
}
str toRuleId(RuleID ID) {
  str ruleId = "";
  ruleId = trim(unparse(ID));
  
  if (ruleId == "") {
    throw "Game rule must define a rule ID";
  }
  return ruleId;
}


list[str] toRuleLogic(Rule gameRuleTree) {
  println(gameRuleTree);

  
  list[str] logic = [];
  visit(gameRuleTree) {
    case RuleParts logicTree: println(toRuleLogic(logicTree));
    //case RuleParts logicTree: logic += [trim(unparse(logicTree))];
  }
  if (logic == []) {
    throw "Game rule must define logic";
  }

  // for (rule <- rules){
  //   Rules::parseLogic(rule);
  // }
  return logic;
}
private RuleLogic toRuleLogic((RuleParts) `(<RuleParts parts>)`)  = toRuleLogic(parts);
private RuleLogic toRuleLogic((RuleParts) `! (<RuleParts parts>)`)  = toRuleLogic(parts);
private RuleLogic toRuleLogic((RuleParts) `not (<RuleParts parts>)`)  = toRuleLogic(parts);
private RuleLogic toRuleLogic((RuleParts) `move piece current`)  =  R_movement(R_currentPiece());
private RuleLogic toRuleLogic((RuleParts) `move piece any`)      =  R_movement(R_anyPiece());
private RuleLogic toRuleLogic((RuleParts) `other player piece any`)      =  R_movement(R_anyPiece()); // TODO: Fix to get otherplayer
private RuleLogic toRuleLogic((RuleParts) `location <RuleLocations l>`)      =  toRuleLocation(l);
private RuleLogic toRuleLogic((RuleParts) `<RuleParts l> -\> <RuleParts r>`) =  R_to(toRuleLogic(l), toRuleLogic(r));
private RuleLogic toRuleLogic((RuleParts) `<RuleParts l> and <RuleParts r>`) =  R_and(toRuleLogic(l), toRuleLogic(r));
private RuleLogic toRuleLogic((RuleParts) `<RuleParts l> && <RuleParts r>`)  =  R_and(toRuleLogic(l), toRuleLogic(r));
private RuleLogic toRuleLogic((RuleParts) `<RuleParts l> || <RuleParts r>`)  =  R_or(toRuleLogic(l), toRuleLogic(r));
private RuleLogic toRuleLogic((RuleParts) `<RuleParts l> == <RuleParts r>`)  =  R_eq(toRuleLogic(l), toRuleLogic(r));
//private RuleLogic toRuleLogic((RuleParts) `<RuleParts l> != <RuleParts r>`)  =  R_neq(toRuleLogic(l), toRuleLogic(r)); // TODO: figure out what is causing the warnings
//private RuleLogic toRuleLogic((RuleParts) `piece any`)  =  R_anyPiece();
//private RuleLogic toRuleLogic((RuleParts) `piece <ID id>`)  =  R_pieceRef(trim(unparse(id)));
//private RuleLogic toRuleLogic((RuleParts) `capture any`)  =  R_capture(R_anyPiece());
private RuleLogic toRuleLogic((RuleParts) `capture <ID id>`)  =  R_capture(R_pieceRef(trim(unparse(id))));
//private RuleLogic toRuleLogic((RuleParts) `capture any`)  =  R_capture(R_anyPiece);

private RuleLogic toRuleLocation((RuleLocations) `{x: <Integer x>, y: <Integer y >}`) = R_location(toInt(unparse(x)), toInt(unparse(y)), R_int(), R_int());
// Store a location that needs to be determined in game
private RuleLogic toRuleLocation((RuleLocations) `{x: <LexicalLocations x>, y: <Integer y >}`) {
  RuleLogic xType = R_any();
  switch(x){
    case (LexicalLocations) `oposite boardedge`: xType = R_boardEdge(true);
    case (LexicalLocations) `boardedge`: xType = R_boardEdge(false);
    case (LexicalLocations) `any`: xType = R_any();
  }
  return R_location(0, toInt(unparse(y)), xType, R_int());
}
// Store a location that needs to be determined in game
private RuleLogic toRuleLocation((RuleLocations) `{x: <Integer x>, y: <LexicalLocations y >}`){
  RuleLogic yType = R_any();
  switch(y){
    case (LexicalLocations) `oposite boardedge`:yType = R_boardEdge(true);
    case (LexicalLocations) `boardedge`:        yType = R_boardEdge(false);
    case (LexicalLocations) `any`:              yType = R_any();
  }
  return R_location(toInt(unparse(x)), 0, R_int(), yType);
}
// Store two locations that needs to be determined in game
private RuleLogic toRuleLocation((RuleLocations) `{x: <LexicalLocations x>, y: <LexicalLocations y >}`){
  RuleLogic xType = R_any();
  RuleLogic yType = R_any();
  switch(x){
    case (LexicalLocations) `oposite boardedge`: xType = R_boardEdge(true);
    case (LexicalLocations) `boardedge`: xType = R_boardEdge(false);
    case (LexicalLocations) `any`: xType = R_any();
  }
  switch(y){
    case (LexicalLocations) `oposite boardedge`: yType = R_boardEdge(true);
    case (LexicalLocations) `boardedge`: yType = R_boardEdge(false);
    case (LexicalLocations) `any`: yType = R_any();
  }
  return R_location(0, 0, xType, yType);
}


str toRuleId(PieceRuleProperty pieceRuleTree) {
  str ruleId = "";
  visit(pieceRuleTree) {
    case RuleID ruleNameTree: if (ruleId == "") ruleId = trim(unparse(ruleNameTree));
  }
  if (ruleId == "") {
    throw "Piece rule must define a rule ID";
  }
  return ruleId;
}
