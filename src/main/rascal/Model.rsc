module Model

import util::Maybe;
import Syntax;

import Model::Rule;
import Model::Gameplay;





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
