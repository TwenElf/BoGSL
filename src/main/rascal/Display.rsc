module Display

import Model;
import Model::Gameplay;
import IO;
import Syntax;
import Exception;
import Gameplay;


void displayASCIIBoard(BoardDef board, GameplayState state) {
  int width = board.width;
  int height = board.height;

  // Create an empty board
  list[list[str]] asciiBoard = [[ "    " | i <- [0..width]] | j <- [0..height]];
  map[str, PieceState] ps = state.pieces;

  // loop through the pieces and place name on the board
  for (<str k, PieceState p> <- [<k,ps[k]> | k <- ps]){
    if (!(p.x >= 0 && p.x < width && p.y >= 0 && p.y < height)) {
        println(p);
        println(k);
        throw("Piece <k> is outside of board bounds");
    }
    asciiBoard[p.y][p.x] = k;
  }


  // Print the board
  str rowSep = "  ";
  for (i <- [0..width]) {
    rowSep += "|------";
  }
  rowSep += "|";

  println(rowSep);
  for ( i <- [height-1..-1]) {
    list[str] row = asciiBoard[i];
    i += 1;
    print("<i> ");
    for (str cell <- row) {
      print("| " + cell + " ");
    }
    println("| ");
    println(rowSep); // Separator between rows
  }

  // Print column labels
  list[str] alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
  list[str] bottomRow = [ "   " + alphabet[i] + "   "| i <- [0..width]];
  print("   ");
  for (str cell <- bottomRow) {
      print(cell);
    }
  println(" ");
  
}