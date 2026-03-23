module Model::Gameplay

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

data PieceState
  = pieceState(int x, int y, Facing facing, map[str, list[Step]] moves)
  ;

data GameplayState
  = gameplayState(str flowState, map[str, PieceState] pieces)
  ;

data AvailableMove
  = availableMove(str playerId, str pieceId, str moveId, int targetX, int targetY)
  ;
