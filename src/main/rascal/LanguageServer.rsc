module LanguageServer

import util::LanguageServer;
import util::PathConfig;
import util::Maybe;
import ParseTree;
import Message;

import Syntax;
import ToModel;
import Model;
import Checks;

private start[Game] parserService(str s, loc l) = parse(#start[Game], s, l);

private loc getLocation(Maybe[loc] l, loc \default) {
  if (just(ll) := l) {
    return ll;
  } else {
    return \default;
  }
}

private Summary ananysisService(loc l, start[Game] g) {
  list[SemanticErrorAt] errors = [];
  if ((start[Game])`<Game nonstart>` := g) {
    GameDef game = toModel(nonstart);
    errors += checkSemantics(game);
  }
  return summary(l,
    messages = {<getLocation(at, g.src), error("<currentError>", getLocation(at, g.src))> | <currentError, at> <- errors}
  );
}

set[LanguageService] languageServices() = {
  parsing(parserService),
  analysis(ananysisService)
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
