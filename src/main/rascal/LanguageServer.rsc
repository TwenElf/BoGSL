module LanguageServer

import util::LanguageServer;
import util::Reflective;
import util::Maybe;
import ParseTree;
import Message;
import analysis::diff::edits::TextEdits;
import String;

import Syntax;
import ToModel;
import Model;
import Checks;

private Tree (str _input, loc _origin) parserService() = parser(#start[Game], allowRecovery=true);

// Return the location in `Maybe`, or use the default.
private loc getLocation(Maybe[loc] l, loc \default) {
  if (just(ll) := l) {
    return ll;
  } else {
    return \default;
  }
}

// Return the symmetric closure of a relation.
// That is, if a R b, then b R a.
private rel[&T, &T] symmetricClosure(rel[&T, &T] r) = r + r<1,0>;

// Return a relation between player uses and their definition.
private rel[loc, loc] playerDefinitions(start[Game] g) {
  rel[str, loc] defs = {<"<player>", player.src> | /PlayerIdProperty playerId := g, /PlayerName player := playerId};
  rel[loc, str] uses = {<player.src, "<player>"> | /PlayerName player := g};
  return (uses + defs<1,0>) o defs;
}

// Return a relation between piece uses and their definition.
private rel[loc, loc] pieceDefinitions(start[Game] g) {
  rel[str, loc] defs = {<"<piece>", piece.src> | /AssignedPiece piece := g};
  rel[loc, str] uses
    = {<piece.src, "<piece>"> | /Action action := g, /ID piece := action}
    + {<piece.src, "<piece>"> | /RuleParts ruleParts := g, /ID piece := ruleParts}
    ;
  return (uses + defs<1,0>) o defs;
}

// Return a relation between chest piece uses and their definition.
private rel[loc, loc] chestPieceDefinitions(start[Game] g) {
  rel[str, loc] defs = {<"<id>", id.src> | /(Piece)`piece <ID id> : { <{PieceProperty ","}* _> }` := g};
  rel[loc, str] uses = {<id.src, "<id>"> | /AssignedPieceType pieceType := g, /ID id := pieceType};
  return (uses + defs<1,0>) o defs;
}

// Return a relation between move uses and their definition.
private rel[loc, loc] moveDefinitions(start[Game] g) {
  rel[str, loc] defs = {<"<move>", move.src> | /PieceProperty piece := g, /MoveID move := piece};
  rel[loc, str] uses = {<move.src, "<move>"> | /Action action := g, /MoveID move := action};
  return (uses + defs<1,0>) o defs;
}

// Rename the symbol under the cursor.
private tuple[list[DocumentEdit], set[Message]] renameService(Focus focus, str newName) {
  if (/start[Game] g := focus) {
    rel[loc, loc] definitions
      = playerDefinitions(g)
      + pieceDefinitions(g)
      + chestPieceDefinitions(g)
      + moveDefinitions(g);
    rel[loc, loc] references = symmetricClosure(definitions)*;
    rel[loc, str] renamingOptions = {<t.src, newName> | Tree t <- focus};
    rel[loc, str] renamings = references o renamingOptions;
    list[TextEdit] edits = [replace(l, s) | <l, s> <- renamings];
    DocumentEdit docEdit = changed(g.src, edits);
    return <[docEdit], {}>;
  }
  return <[], {error("Renaming failed", focus[0].src.top)}>;
}

// Check if there is something to rename under the cursor.
private loc renamePreparingService(Focus focus) {
  if (/start[Game] g := focus) {
    rel[loc, loc] definitions
      = playerDefinitions(g)
      + pieceDefinitions(g)
      + chestPieceDefinitions(g)
      + moveDefinitions(g);
    rel[loc, loc] references = symmetricClosure(definitions)*;
    set[loc] identifiers = references<0>;
    set[loc] focusLocations = {t.src | Tree t <- focus};
    set[loc] renameSource = identifiers & focusLocations;
    if (renameSource == {}) {
      throw "Nothing to rename here";
    }
    return focus[0].src;
  }
  throw "Renaming failed";
}

// Analyze the code for errors, definitions and references.
private Summary analysisService(loc l, start[Game] g) {
  list[SemanticErrorAt] errors = [];

  if ((start[Game])`<Game nonstart>` := g) {
    GameDef game = toModel(nonstart);
    errors += checkSemantics(game);
  }

  rel[loc, loc] definitions
    = playerDefinitions(g)
    + pieceDefinitions(g)
    + chestPieceDefinitions(g)
    + moveDefinitions(g);

  return summary(l,
    messages = {<getLocation(at, g.src), error("<currentError>", getLocation(at, g.src))> | <currentError, at> <- errors},
    definitions = definitions,
    references = symmetricClosure(definitions)*
  );
}

// Give completion suggestions.
private list[CompletionItem] completionService(Focus focus, int cursorOffset, CompletionTrigger trigger) {
  Tree t = focus[0];
  str prefix = "<t>"[..cursorOffset];
  int cc = t.src.begin.column + cursorOffset;

  bool isTypingId = false;
  try {
    if (prefix != "" && trim(prefix) == prefix) {
      parse(#ID, prefix);
      isTypingId = true;
    }
  } catch ParseError(_): {;}

  set[str] keywords = {
    "game", "chest", "actions", "board", "piece", "direction", "move",
    "north", "south", "east", "west", "forward", "backward", "left", "right",
    "action", "ID", "flow", "start", "end", "gameOver", "moved", "noMoves",
    "players", "id", "pieces", "type", "initialPosition", "machine", "state",
    "rule", "current", "any", "capture", "move", "piece"
  };

  Tree g = focus[-1];
  rel[str, CompletionItemKind, str] defs
    = {<"<player>", \variable(), "player"> | /PlayerIdProperty playerId := g, /PlayerName player := playerId}
    + {<"<piece>", \variable(), "piece"> | /AssignedPiece piece := g}
    + {<"<id>", \variable(), "chest piece"> | /(Piece)`piece <ID id> : { <{PieceProperty ","}* _> }` := g}
    + {<"<move>", \variable(), "move"> | /PieceProperty piece := g, /MoveID move := piece}
    + {<kw, \constant(), "keyword"> | kw <- keywords}
    ;
  map[CompletionItemKind, str] kindSort = (\variable(): "a", \constant(): "b");

  return [
    completionItem(
      kind,
      isTypingId
        ? completionEdit(t.src.begin.column, cc, t.src.end.column, name)
        : completionEdit(cc, cc, cc, name),
      name,
      labelDetail = " <label>",
      sortText = kindSort[kind] + label + name
    ) | <name, kind, label> <- defs
  ];
}

set[LanguageService] languageServices() = {
  parsing(parserService()),
  analysis(analysisService),
  rename(renameService, prepareRenameService = renamePreparingService),
  completion(completionService)
};

int main() {
  registerLanguage(
    language(
      pathConfig(srcs=[|project://BoGSL/src/main/rascal|]),
      "BoGSL", // name of the language
      {"dsl"}, // extension
      "LanguageServer", // module to import
      "languageServices"
    )
  );
  return 0;
}
