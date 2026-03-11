module Main

import IO;
import Gameplay;
import ToModel;
import Parser;
import Syntax;import Model;
import Display;



int main() {
    loc filename = |cwd:///src/main/rascal/exampleGame4.dsl|;
    GameDef game = parseCheckGameModelFile(filename);

    GameplayState state = newGameplayState(game);
    displayASCIIBoard(game.board, state);
    state = doActions(game);
    displayASCIIBoard(game.board, state);
    return 0;
}
