module Syntax



// ---------- Lexical tokens ----------

lexical Integer
  = [0-9]+
  ;

keyword KW
  = "game" | "chest" | "actions" | "board" | "piece" | "direction" | "move"
  | "north" | "south" | "east" | "west" | "forward" | "backward" | "left" | "right" | "action" | "ID"
  | "flow" | "start" | "end" | "gameOver" | "moved" | "noMoves"
  | "players" | "id" | "pieces" | "type" | "initialPosition" | "machine" | "state"
  | "rule"
  ;

lexical ID
  = [A-Za-z_][A-Za-z0-9_]* !>> [A-Za-z0-9_] \ KW
  ;

lexical MoveID
  = [A-Za-z0-9_]+
  ;

// ---------- Layout (whitespace) ----------
layout Whitespace 
  = [\ \t\n\r]* !>> [\ \t\n\r]
  ;

// ---------- Game syntax ----------
start syntax Game
  = "game" ":" "{" GameProperty ("," GameProperty)* "}"
  ;

syntax GameProperty
  = "chest"   ":" Chest
  | "actions" ":" Actions
  | "board"   ":" Board
  | "players" ":" Players
  | GameRuleProperty
  | "flow"    ":" Flow
  ;

syntax Players
  = "[" { PlayerDefinition "," }* PlayerDefinition? "]"
  ;

syntax PlayerDefinition
  = PlayerIdProperty "," PlayerPiecesProperty
  ;

syntax PlayerIdProperty
  = "id" ":" PlayerName
  ;

syntax PlayerPiecesProperty
  = "pieces" ":" PieceAssignments
  ;

syntax PlayerName
  = ID
  ;

syntax GameRuleProperty
  = "rule" ":" RuleName
  ;

syntax PieceAssignments
  = "{" { PieceAssignment "," }* PieceAssignment? "}"
  ;

syntax PieceAssignment
  = AssignedPiece ":" "{" PieceAssignmentProperties? "}"
  ;

syntax PieceAssignmentProperties
  = PieceAssignmentProperty (","? PieceAssignmentProperty)*
  ;

syntax PieceAssignmentProperty
  = TypeAssignmentProperty
  | DirectionAssignmentProperty
  | InitialPositionAssignmentProperty
  ;

syntax TypeAssignmentProperty
  = "type" ":" AssignedPieceType
  | "type" AssignedPieceType
  ;

syntax DirectionAssignmentProperty
  = "direction" ":" FacingDirection
  ;

syntax InitialPositionAssignmentProperty
  = "initialPosition" ":" InitialPosition
  ;

syntax InitialPosition
  = "{" "x" ":" Integer "," "y" ":" Integer "}"
  ;

syntax AssignedPiece
  = ID
  ;

syntax AssignedPieceType
  = ID
  ;

// ---------- Pieces syntax ----------
syntax Chest // chest as in pieces chest
  = "[" {Piece ","}* Piece? "]"
  ;

syntax Piece
  = "piece" ID ":" "{" { PieceProperty "," }* PieceProperty? "}"
  ;

syntax PieceProperty
  = "move" Movement
  | PieceRuleProperty
  ;

syntax PieceRuleProperty
  = "rule" ":" RuleName
  ;

syntax Movement
  = MoveID  ":" "{" Direction? ("," Direction)* "}"
  ;

syntax Direction
  = "forward" Integer
  | "backward" Integer
  | "left" Integer
  | "right" Integer
  ;

syntax FacingDirection
  = "north"
  | "south"
  | "east"
  | "west"
  ;

// ---------- Game syntax ----------
syntax Actions
  = "["  { Action ","}* Action? "]"
  ;

syntax Action
  = "action" ":" "{" "ID" ":" ID "," "move" ":" MoveID "}"
  ;


syntax Board
  = "{" "width" ":" Integer "," "height" ":" Integer "}"
  ;

// ---------- Flow syntax ----------
syntax Flow
  = "{" "start" ":" StartState "," "end" ":" EndState "," "machine" ":" Machine "}"
  ;

syntax StartState
  = PlayerName
  ;

syntax EndState
  = GameOverState
  ;

syntax Machine
  = "[" { FlowState "," }* FlowState? "]"
  ;

syntax FlowState
  = "state" StateName ":" "{" StateTransitions? "}"
  ;

syntax StateName
  = PlayerName
  ;

syntax StateTransition
  = TransitionEvent Arrow TransitionTarget
  ;

syntax StateTransitions
  = StateTransition ("," StateTransition)*
  ;

syntax TransitionEvent
  = "moved"
  | "noMoves"
  ;

syntax TransitionTarget
  = PlayerName
  ;

syntax Arrow
  = "-" "\>"
  ;

syntax RuleName
  = ID
  ;

syntax GameOverState
  = "gameOver"
  ;
