module Interactive

import IO;
import Gameplay;
import Parser;
import Display;
import Model;

import String;   // Required for toInt()
import List;     // Required for size()

// Helper to show board + current flow state / player
void displayGameState(GameDef game, GameplayState state) {
  println("Current flow state (player or gameOver): <state.flowState>");
  displayASCIIBoard(game.board, state);
}

void showAvailableMoves(list[AvailableMove] moves) {
  if (moves == []) {
    println("  (No moves available)");
    return;
  }

  int i = 0;
  for (AvailableMove m <- moves) {
    println("<i>: <m.playerId> <m.pieceId> uses <m.moveId> to (<m.targetX>, <m.targetY>)");
    i += 1;
  }
}

void playInteractive(loc filename) {
  GameDef game = parseCheckGameModelFile(filename);
  GameplayState state = newGameplayState(game);

  while (state.flowState != game.flow.endState) {
    displayGameState(game, state);

    // // If we are in a non-player state, just stop (should normally be only gameOver)
    // if (!isPlayerState(game, state.flowState)) {
    //   println("Non-player flow state <state.flowState>, stopping.");
    //   break;
    // }

    list[AvailableMove] moves = currentPlayerAvailableMoves(game, state);

    if (moves == []) {
      println("No moves available.");
      // Delegate a "noMoves" turn to doFlowTurn, which already
      // computes available moves and advances the flow based on the event.
      // instead of using something from Gameplay
      state = doFlowTurn(state, game);
      continue;
    }

    println("Available moves for <state.flowState>:");
    showAvailableMoves(moves);

    println("Choose move index (or -1 to quit): ");
    
    // Need something that can read the inputs
    str readInput = readFileLines(|stdin:///|)[0];

    try {
      int choice = toInt(trim(readInput));
      if (choice < 0) {
        println("Game aborted by user.");
        break;
      }
      if (choice >= size(moves)) {
        println("Invalid choice.");
        continue;
      }

      AvailableMove chosen = moves[choice];
      // Apply the chosen move
      state = doAction(state, game, actionDef(chosen.pieceId, chosen.moveId));
      // Advance the flow by delegating to doFlowTurn.
      // See a move was made and use "moved" as the event.
      state = doFlowTurn(state, game);
    }
    catch e: {
      println("Invalid input. Please enter a number.");
      continue;
    }
  }

  displayASCIIBoard(game.board, state);
  println("Reached flow state <state.flowState>.");
}
