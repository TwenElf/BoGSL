module Main

import IO;
import Gameplay;
import Parser;
import Display;
import Model;
import UI;

void printAvailableMoves(list[AvailableMove] moves) {
    if (moves == []) {
        println("  (none)");
        return;
    }

    for (AvailableMove available <- moves) {
        println("  <available>");
    }
}

void testAvailableMovesChess() {
    loc filename = |cwd:///example/chess.dsl|;
    GameDef game = parseCheckGameModelFile(filename);
    GameplayState state = newGameplayState(game);

    println("Initial board (chess.dsl):");
    displayASCIIBoard(game.board, state);

    list[AvailableMove] whiteMoves = availableMoves(game, state, "white");
    list[AvailableMove] blackMoves = availableMoves(game, state, "black");

    println("Available moves for white:");
    printAvailableMoves(whiteMoves);
    println("Available moves for black:");
    printAvailableMoves(blackMoves);
}

UIApp main() {
    testAvailableMovesChess();

    loc filename = |cwd:///example/chess.dsl|;
    GameDef game = parseCheckGameModelFile(filename);

    GameplayState state = newGameplayState(game);
    return startUI(game, state);
}
