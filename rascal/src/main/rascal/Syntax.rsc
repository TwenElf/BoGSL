module Syntax



// ---------- Lexical tokens ----------

lexical Integer
  = [0-9]+
  ;

// A simple, teaching-friendly identifier rule:
// - starts with letter/_
// - continues with letters/digits/_
// - and must not be exactly a keyword
lexical ID 
  = [A-Za-z_][A-Za-z0-9_]* ![A-Za-z0-9_]
  | [A-Za-z_][A-Za-z0-9_]*
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
  = "game" ":" "{" (GameProperty ("," GameProperty)*)? "}"
  ;

syntax GameProperty
  = "chest"   ":" Chest
  | "actions" ":" Actions
  | "board"   ":" Board
  ;

// TODO: Correct trailing comma handling in the syntax rules below
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

