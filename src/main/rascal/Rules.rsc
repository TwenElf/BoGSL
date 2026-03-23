module Rules

import Model;
import Model::Rule;
import Model::Gameplay;
import ToModel;
import Gameplay;
import List;

import IO;





public bool checkRules(GameDef game, GameplayState state) {
  list[RuleDef] rules = getRules(game);
  //println(rules);
  map[str, bool] results = ();
  for(RuleDef rule <- rules){
    switch (rule) {
        case gameRuleDef(str ruleId, RuleLogic logic): results = results +  (  ruleId:  checkGameRule(game, logic));
        case moveRuleDef(str ruleId, RuleLogic logic): results = results +  (  ruleId:  checkGameRule(game, logic));
        case startTurnRuleDef(str ruleId, RuleLogic logic): results = results +  (  ruleId:  checkGameRule(game, logic));
        case endTurnRuleDef(str ruleId, RuleLogic logic): results = results +  (  ruleId:  checkGameRule(game, logic));
    }
  }
  return true;
}

public bool checkRules(GameDef game, GameplayState state, ActionDef action) {
  list[RuleDef] rules = getRules(game);
  println(action);
  map[str, bool] results = ();
  for(RuleDef rule <- rules){
    switch (rule) {
        case moveRuleDef(str ruleId, RuleLogic logic): results = results +  (  ruleId:  checkGameRule(game,state,action, logic));
    }
  }
  println(results);
  for( res <- results){
    if(results[res] == true){
      throw "<res> is true for action <action>";
    }
  }
  
  return true;
}

// public bool checkRule(GameDef game, RuleDef rule) {
//   switch (rule) {
//     case gameRuleDef(str ruleId, list[str] logic): return checkGameRule(game, logic);
//     //case pieceRuleDef(str pieceId, str ruleId): return checkPieceRule(game, pieceId, ruleId);
//   }
//   return true;
// }

private bool checkGameRule(GameDef game, list[str] rules) {
  // Placeholder for actual game rule logic checking
  //println(rules);
  return true;
}

private bool checkGameRule(GameDef game, RuleLogic rule) {
  return true;
}


// Check the game rule for a movement going to a location
private bool checkGameRule(GameDef game,  GameplayState state , ActionDef action, R_to(R_movement(left), RuleLogic right)){
  println("Moving <left> to <right>");
  int moveToX = 0;
  int MoveToY = 0;
  <moveToX, MoveToY> = checkGameRule(game,state,action, left);
  switch(right){
    case R_location(_,_,_,_):right = ruleEvalLocation( game,  state,  action,  right);
  }
  //if(right:=R_location())  evalLocation(game,state,action,right);
  switch(right){
    case R_location(int x, int y, R_int(), R_int()): return (moveToX == x && MoveToY == y); // check location directly
    case R_location(int x, int _, R_int(), R_any()): return (moveToX == x); // One of the locations is any possible location
    case R_location(int _, int y, R_any(), R_int()): return (MoveToY == y); // One of the locations is any possible location
  }
  return false;
}



// does the same actions as DoAction to determine the movement that the current piece will do
// returns the location the piece will end up in
private tuple[int x, int y] checkGameRule(GameDef game, GameplayState state, ActionDef action, R_currentPiece() ){
  PieceState piece = state.pieces[action.pieceId];
  list[Step] steps = piece.moves[action.moveId];
  for (Step step <- steps) {
    piece = doMove(piece, step);
  }
  return <piece.x, piece.y>;
}

// Updates the location used in a rule based on the current action
// if BoardEdge is used it updates the edge based on orientation of the piece.
private RuleLogic ruleEvalLocation(  GameDef game,  GameplayState state,  ActionDef action,  RuleLogic logic) {
  Facing dir = state.pieces[action.pieceId].facing;
  println(logic);
  println("<action.pieceId> <state.pieces[action.pieceId]>");
  switch (logic) {
    case R_location(x, y, xType, yType):{
      switch(xType){
        case R_boardEdge(true): {x = dir:=northFacing()? 0:game.board.width; xType= R_int();}
        case R_boardEdge(false): {x = dir:=northFacing()?  game.board.width: 0;  ; xType= R_int();}
      }
      switch(yType){
        case R_boardEdge(true): {y = dir:=northFacing()? 0: game.board.height; yType = R_int();}
        case R_boardEdge(false): {y = dir:=northFacing()?  game.board.height:0; yType = R_int();}
      }
      println("EvalLocation: x:<x>, y:<y> <xType> <yType>");
      return R_location( x, y, xType, yType);}
    default:
      throw "expected R_location";
  }
}


private list[RuleDef] getRules(GameDef game){
  return game.rules;
}



