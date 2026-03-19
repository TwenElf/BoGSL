module Rules

import Model;
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
  //println(rules);
  map[str, bool] results = ();
  for(RuleDef rule <- rules){
    switch (rule) {
        case moveRuleDef(str ruleId, RuleLogic logic): results = results +  (  ruleId:  checkGameRule(game,state,action, logic));
    }
  }
  println(results);
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
    case R_location(int x, int y, true, true): return (moveToX == x && MoveToY == y);
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

// private bool checkGameRule(GameDef game, RuleLogic rule, ActionDef action) {
//   // Placeholder for actual game rule logic checking
//   //println(rules);
//   return true;
// }

private list[RuleDef] getRules(GameDef game){
  return game.rules;
}



