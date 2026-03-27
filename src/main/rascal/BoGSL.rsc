module BoGSL

import Gameplay;
import Parser;
import Model;
import UI;

UIApp playBoGSL(loc location) {
    GameDef game = parseCheckGameModelFile(location);
    GameplayState state = newGameplayState(game);
    return startUI(game, state);
}

UIApp playChess() = playBoGSL(|cwd:///example/chess.dsl|);

UIApp playLine() = playBoGSL(|cwd:///example/line.dsl|);
