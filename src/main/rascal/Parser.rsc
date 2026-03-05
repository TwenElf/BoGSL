module Parser

import Syntax;
import ParseTree;
import IO;
import Set;
import String;

// Parses the file with the game code and returns the parse tree
Game parseGameFile(loc fileloc) {
  str s = readFile(fileloc);
  println("<s>");
  Game tree = parse(#Game, trim(s));
  checkGame(tree);

  return tree;
}

Game parseGame(str input) {
  println("<input>");
  Game tree = parse(#Game, trim(input));
  checkGame(tree);
  return tree;
}

Chest parseChest(str input) {
  Chest tree = parse(#Chest, trim(input));
  return tree;
}

Chest parseChestFile(loc fileloc) {
  str s = readFile(fileloc);
  println("<s>");
  return parse(#Chest, trim(s));
}


// checks that some basics like board,actions and chest are defined and not duplicated
void checkGame(Game g){
  nChest = 0;
  nBoard = 0;
  nActions = 0;
  visit(g){
    case Chest _: nChest += 1;
    case Actions _: nActions += 1;
    case Board _: nBoard += 1;
  }
  if (nChest != 1) throw  nChest == 0 ? "No chest defined" :"Multiple chests defined" ;
  if (nActions != 1) throw nActions == 0 ? "No actions defined" :  "Multiple actions defined" ;
  if (nBoard != 1) throw nBoard == 0 ? "No board defined" : "Multiple boards defined" ;
  return;
}
