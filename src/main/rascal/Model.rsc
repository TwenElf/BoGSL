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

data GameDef
  = gameDef(BoardDef board, list[PieceDef] pieces, list[ActionDef] actions)
  ;
