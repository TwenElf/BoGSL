module Syntax



// ---------- Lexical tokens ----------

lexical Integer
  = [0-9]+
  ;

keyword KW
  = "game" | "chest" | "actions" | "board" | "piece" | "direction" | "move"
  | "north" | "south" | "east" | "west" | "forward" | "backward" | "left" | "right" | "action" | "ID"
  | "flow" | "start" | "end"
  | "players" | "machine" | "state"
  | "rule"
  ;

lexical ID
  = [A-Za-z_][A-Za-z0-9_]* !>> [A-Za-z0-9_]
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
  | "rules" ":" Rules
  | "flow"    ":" Flow
  ;

syntax Players
  = "[" { PlayerName "," }* PlayerName? "]"
  ;

syntax PlayerName
  = ID
  ;


// ---------- Pieces syntax ----------
syntax Chest // chest as in pieces chest
  = "{" {Piece ","}* Piece? "}"
  ;

syntax Piece
  = "piece" ID ":" "{" { Properties "," }* Properties? "}"
  ;

syntax Properties
  = "direction" ":" FacingDirection
  | "move" Movement
  | PieceRuleProperty
  ;

syntax PieceRuleProperty
  = "rule" ":" RuleID
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
  = ID
  ;

syntax EndState
  = ID
  ;

syntax Machine
  = "{" { FlowState "," }* FlowState? "}"
  ;

syntax FlowState
  = "state" StateName ":" "{" StateTransitions? "}"
  ;

syntax StateName
  = ID
  ;

syntax StateTransition
  = TransitionEvent Arrow TransitionTarget
  ;

syntax StateTransitions
  = StateTransition ("," StateTransition)*
  ;

syntax TransitionEvent
  = ID
  ;

syntax TransitionTarget
  = ID
  ;



syntax Arrow
  = "-" "\>"
  ;

// ---------- Rules syntax ----------

syntax Rules
  = "{" Rule? ("," Rule)* "}"
  ;

syntax Rule
  = "rule" RuleID ":"  RuleParts*
  ;

// syntax RuleProperties
//   = "piece" RuleName ":" RuleParts*
//   ;
syntax RuleParts
  = "move" "piece" "any"
  | "other player"
  | "piece" ID
  | "boardsize" 
  | "capture" ID
  | "can"
  | Loop
  | Logicals
  ;

syntax Logicals
  = "\>"
  | "\<"
  | "=="
  | "!="
  | "and"
  | "or"
  | "||"
  | "&&"
  | "\<="
  | "\>="
  | Arrow // reusing arrow for move to
  ;

syntax Loop
  = "for" "(" ("each" | "all") "moves" "piece" ID ")"
  ;

syntax RuleID
  = ID
  ;
