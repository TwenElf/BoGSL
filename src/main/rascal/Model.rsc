module Model

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
  = moveDef(str name, list[Step] steps, Maybe[Movement] tree = nothing())
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

data BoardDef
  = boardDef(int width, int height, Maybe[Board] tree = nothing())
  ;

data ActionDef
  = actionDef(str pieceId, str moveId, Maybe[Action] tree = nothing())
  ;

data TransitionDef
  = transitionDef(str event, str toState, Maybe[StateTransition] tree = nothing())
  ;

data StateDef
  = stateDef(str name, list[TransitionDef] transitions, Maybe[FlowState] tree = nothing())
  ;

data FlowDef
  = flowDef(str startState, str endState, list[StateDef] states, Maybe[Flow] tree = nothing())
  ;

data RuleDef
  = gameRuleDef(str ruleId, Maybe[GameRuleProperty] gameRuleTree = nothing())
  | pieceRuleDef(str pieceId, str ruleId, Maybe[PieceRuleProperty] pieceRuleTree = nothing())
  ;

data GameDef
  = gameDef(
      BoardDef board,
      list[PieceDef] pieces,
      list[PieceAssignmentDef] assignedPieces,
      list[ActionDef] actions,
      FlowDef flow,
      list[RuleDef] rules,
      list[str] players,
      Maybe[Game] tree = nothing(),
      Maybe[Players] playersTree = nothing()
    )
  ;
