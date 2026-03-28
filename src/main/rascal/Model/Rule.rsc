module Model::Rule

data RuleDef
  = gameRuleDef(str ruleId, RuleLogic logic)
  | pieceRuleDef(str pieceId, str ruleId)
  | moveRuleDef(str ruleId, RuleLogic logic)
  | startTurnRuleDef(str ruleId, RuleLogic logic)
  | endTurnRuleDef(str ruleId, RuleLogic logic)
  ;

data RuleLogic
  // control / composition
  = R_to(RuleLogic left, RuleLogic right)
  | R_iftrue(RuleLogic logic)

  // boolean logic
  | R_and(RuleLogic left, RuleLogic right)
  | R_or(RuleLogic left, RuleLogic right)
  | R_eq(RuleLogic left, RuleLogic right)
  | R_neq(RuleLogic left, RuleLogic right)
  | R_not(RuleLogic logic)
  | R_false()
  | R_true()

  // action / movement
  | R_movement(RuleLogic logic)
  | R_capture(RuleLogic logic)

  // piece selection
  | R_currentPiece()
  | R_anyPiece()
  | R_pieceRef(str pieceTypeId)
  | R_oppponent(RuleLogic piece)

  // player-relative selectors
  | R_playerCurrent(RuleLogic entity)
  | R_playerOther(RuleLogic entity)

  // location
  | R_location(int x, int y, RuleLogic xType, RuleLogic yType)
  | R_location(RuleLogic piece)
  | R_any()
  | R_boardEdge(bool opposite) // the boolean stores is true if the opposite board edge is selected
  | R_int()
;

