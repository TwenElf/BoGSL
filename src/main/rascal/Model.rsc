module Model

import Model::Rule;
import Model::Gameplay;





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
