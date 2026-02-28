module Parser

import Syntax;
import ParseTree;
import IO;
import Set;

// Parses the file with the game code and returns the parse tree
Game parseGameFile(loc fileloc) {
  str s = readFile(fileloc);
  println("<s>");
  return parse(#Game, fileloc);
}

Chest parseChest(str input) {
  Chest tree = parse(#Chest, input);
  return tree;
}

Chest parseChestFile(loc fileloc) {
  str s = readFile(fileloc);
  println("<s>");
  return parse(#Chest, fileloc);
}