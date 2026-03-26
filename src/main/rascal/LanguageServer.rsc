module LanguageServer

import util::LanguageServer;
import util::PathConfig;
import ParseTree;
import Message;

import Syntax;
import ToModel;
import Model;
import Checks;

private start[Game] parserService(str s, loc l) = parse(#start[Game], s, l);

private Summary ananysisService(loc l, start[Game] g) {
  list[SemanticError] errors = [];
  if ((start[Game])`<Game nonstart>` := g) {
    GameDef game = toModel(nonstart);
    errors += checkSemantics(game);
  }
  return summary(l,
    messages = {<g.src, error("<currentError>", g.src)> | currentError <- errors}
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
