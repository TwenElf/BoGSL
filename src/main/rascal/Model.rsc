module Model

data Facing
  = northFacing()
  | southFacing()
  | eastFacing()
  | westFacing()
  ;

data Step
  = forwardStep(int amount)
  | backwardStep(int amount)
  | leftStep(int amount)
  | rightStep(int amount)
  ;

data MoveDef
  = moveDef(str name, list[Step] steps)
  ;

data PieceDef
  = pieceDef(str name, list[MoveDef] moves)
  ;

data PositionDef
  = positionDef(int x, int y)
  ;

data PieceAssignmentDef
  = pieceAssignmentDef(str playerId, str pieceId, str typeId, Facing direction, PositionDef initialPosition)
  ;

data BoardDef
  = boardDef(int width, int height)
  ;

data ActionDef
  = actionDef(str pieceId, str moveId)
  ;

data TransitionDef
  = transitionDef(str event, str toState)
  ;

data StateDef
  = stateDef(str name, list[TransitionDef] transitions)
  ;

data FlowDef
  = flowDef(str startState, str endState, list[StateDef] states)
  ;

data RuleDef
  = gameRuleDef(str ruleId, RuleLogic logic)
  | pieceRuleDef(str pieceId, str ruleId)
  | moveRuleDef(str ruleId, RuleLogic logic)
  | startTurnRuleDef(str ruleId, RuleLogic logic)
  | endTurnRuleDef(str ruleId, RuleLogic logic)
  ;

data RuleLogic
  = R_to(RuleLogic left, RuleLogic right)
  | R_iftrue(RuleLogic logic)
  | R_movement(RuleLogic logic)
  | R_and(RuleLogic left, RuleLogic right)
  | R_or(RuleLogic left, RuleLogic right)
  | R_eq(RuleLogic left, RuleLogic right)
  | R_neq(RuleLogic left, RuleLogic right)
  | R_currentPiece()
  | R_anyPiece()
  | R_pieceID(str id)
  | R_piece(PieceDef piece)
  | R_playerCurrent(RuleLogic entity)
  | R_playerOther(RuleLogic entity)
  | R_location(int x, int y, bool x_check, bool y_check)
  | R_capture(RuleLogic logic)
  ;



data GameDef
  = gameDef(
      BoardDef board,
      list[PieceDef] pieces,
      list[PieceAssignmentDef] assignedPieces,
      list[ActionDef] actions,
      FlowDef flow,
      list[RuleDef] rules,
      list[str] players
    )
  ;
