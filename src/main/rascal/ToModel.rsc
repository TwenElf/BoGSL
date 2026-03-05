module ToModel

import Model;
import ParseTree;
import String;
import Syntax;

GameDef toModel(Game gameTree) {
  Board boardTree = firstBoard(gameTree);
  Chest chestTree = firstChest(gameTree);
  Actions actionsTree = firstActions(gameTree);

  return gameDef(
    toBoardDef(boardTree),
    toPieceDefs(chestTree),
    toActionDefs(actionsTree)
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

private Actions firstActions(Game gameTree) {
  list[Actions] allActions = [];
  visit(gameTree) {
    case Actions actionsTree: allActions += [actionsTree];
  }

  if (size(allActions) == 0) {
    throw "Game has no actions";
  }

  return allActions[0];
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

list[PieceDef] toPieceDefs(Chest chestTree) {
  list[PieceDef] pieces = [];
  visit(chestTree) {
    case Piece pieceTree: pieces += [toPieceDef(pieceTree)];
  }
  return pieces;
}

PieceDef toPieceDef(Piece pieceTree) {
  str pieceName = "";
  list[Facing] directions = [];
  list[MoveDef] moves = [];

  visit(pieceTree) {
    case ID nameTree: if (pieceName == "") pieceName = unparse(nameTree);
    case FacingDirection directionTree: directions += [toFacing(directionTree)];
    case Movement movementTree: moves += [toMoveDef(movementTree)];
  }

  if (pieceName == "") {
    throw "Piece has no identifier";
  }

  return pieceDef(pieceName, directions, moves);
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

  visit(movementTree) {
    case MoveID moveIdTree: if (moveName == "") moveName = unparse(moveIdTree);
    case Direction directionTree: steps += [toStep(directionTree)];
  }

  if (moveName == "") {
    throw "Move has no identifier";
  }

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
