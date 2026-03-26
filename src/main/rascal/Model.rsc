module Model

import util::Maybe;
import Syntax;

data Facing
  = northFacing(Maybe[FacingDirection] tree)
  | southFacing(Maybe[FacingDirection] tree)
  | eastFacing(Maybe[FacingDirection] tree)
  | westFacing(Maybe[FacingDirection] tree)
  ;

data Step
  = forwardStep(int amount, Maybe[Direction] tree)
  | backwardStep(int amount, Maybe[Direction] tree)
  | leftStep(int amount, Maybe[Direction] tree)
  | rightStep(int amount, Maybe[Direction] tree)
  ;

data MoveDef
  = moveDef(str name, list[Step] steps, Maybe[Movement] tree)
  ;

data PieceDef
  = pieceDef(str name, list[MoveDef] moves, Maybe[Piece] tree)
  ;

data PositionDef
  = positionDef(int x, int y, Maybe[InitialPosition] tree)
  ;

data PieceAssignmentDef
  = pieceAssignmentDef(str playerId, str pieceId, str typeId, Facing direction, PositionDef initialPosition, Maybe[PieceAssignment] tree)
  ;

data BoardDef
  = boardDef(int width, int height, Maybe[Board] tree)
  ;

data ActionDef
  = actionDef(str pieceId, str moveId, Maybe[Action] tree)
  ;

data TransitionDef
  = transitionDef(str event, str toState, Maybe[StateTransition] tree)
  ;

data StateDef
  = stateDef(str name, list[TransitionDef] transitions, Maybe[FlowState] tree)
  ;

data FlowDef
  = flowDef(str startState, str endState, list[StateDef] states, Maybe[Flow] tree)
  ;

data RuleDef
  = gameRuleDef(str ruleId, Maybe[GameRuleProperty] gameRuleTree)
  | pieceRuleDef(str pieceId, str ruleId, Maybe[PieceRuleProperty] pieceRuleTree)
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
      Maybe[Game] tree,
      Maybe[Players] playersTree
    )
  ;
