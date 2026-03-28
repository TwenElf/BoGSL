module Model::Gameplay
import Model::Rule;
import util::Maybe;
import Syntax;

data Facing
  = northFacing(Maybe[FacingDirection] tree = nothing())
  | southFacing(Maybe[FacingDirection] tree = nothing())
  | eastFacing(Maybe[FacingDirection] tree = nothing())
  | westFacing(Maybe[FacingDirection] tree = nothing())
  ;

data Step
  = forwardStep(int amount, Maybe[Direction] tree = nothing())
  | backwardStep(int amount, Maybe[Direction] tree = nothing())
  | leftStep(int amount, Maybe[Direction] tree = nothing())
  | rightStep(int amount, Maybe[Direction] tree = nothing())
  ;

data MoveDef
  = moveDef(str name, list[Step] steps, RuleDef rule,Maybe[Movement] tree = nothing()) // add the possibility for a movement to contain a rule.
  | moveDef(str name, list[Step] steps,Maybe[Movement] tree = nothing())
  ;

data PieceDef
  = pieceDef(str name, list[MoveDef] moves, Maybe[Piece] tree = nothing())
  ;

data PositionDef
  = positionDef(int x, int y, Maybe[InitialPosition] tree = nothing())
  ;

data PieceAssignmentDef
  = pieceAssignmentDef(str playerId, str pieceId, str typeId, Facing direction, PositionDef initialPosition, Maybe[PieceAssignment] tree = nothing())
  ;

data PieceState
  = pieceState(int x, int y, Facing facing, map[str, MoveDef] moves)
  ;

data GameplayState
  = gameplayState(str flowState, map[str, PieceState] pieces)
  ;

data AvailableMove
  = availableMove(str playerId, str pieceId, str moveId, int targetX, int targetY)
  ;
