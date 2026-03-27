module BoGSL

import Gameplay;
import Parser;
import Model;
import UI;
import IO;
import String;

UIApp playBoGSL(loc location) {
    GameDef game = parseCheckGameModelFile(location);
    GameplayState state = newGameplayState(game);
    return startUI(game, state);
}

UIApp playChess() = playBoGSL(|cwd:///example/chess.dsl|);

UIApp playLine() = playBoGSL(|cwd:///example/line.dsl|);

void main(list[str] args) {
    loc fileLoc = |file:///|[path=args[0]];
    int port = toInt(args[1]);
    GameDef game = parseCheckGameModelFile(fileLoc);
    GameplayState state = newGameplayState(game);
    println("Serving BoGSL at http://localhost:<port> - open in browser (Ctrl+C to stop)");
    serveUI(game, state, |http://localhost:1|[port=port]);
}
