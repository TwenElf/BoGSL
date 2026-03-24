module LanguageServer

import util::LanguageServer;
import Syntax;
import ParseTree;
import util::PathConfig;

private start[Game] parserService(str s, loc l) = parse(#start[Game], s, l);

set[LanguageService] languageServices() = {
  parsing(parserService)
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
