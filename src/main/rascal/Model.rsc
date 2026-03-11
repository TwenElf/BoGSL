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
  = pieceDef(str name, list[Facing] directions, list[MoveDef] moves)
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
  = gameRuleDef(str ruleId, list[str] logic)
  | pieceRuleDef(str pieceId, str ruleId)
  ;

data GameDef
  = gameDef(
      BoardDef board,
      list[PieceDef] pieces,
      list[ActionDef] actions,
      FlowDef flow,
      list[RuleDef] rules,
      list[str] players
    )
  ;
