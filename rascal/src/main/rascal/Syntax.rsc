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
  = "game" ":" "{" "chest" ":" Chest "," "actions" ":" Actions "}"
  ;

// TODO: Correct trailing comma handling in the syntax rules below
// ---------- Pieces syntax ----------
syntax Chest // chest as in pieces chest
  = {Piece ";"}*
  ;

syntax Piece
  = "piece" ID ":" "{" { Movement "," }* "}"
  ;

syntax Movement
  = "move" MoveID  ":" "{" {Direction ","}* "}"
  ;

syntax Direction
  = "forward" Integer
  | "backward" Integer
  | "left" Integer
  | "right" Integer
  ;


// ---------- Game syntax ----------
syntax Actions
  = "{" {Action ","}* "}"
  ;

syntax Action
  = "action" ":" "{" "ID" ":" ID "," "move" ":" MoveID "}"
  ;


