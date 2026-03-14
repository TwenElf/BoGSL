module Parser

import Checks;
import Model;
import Syntax;
import ParseTree;
import ToModel;
import IO;
import Set;
import String;

// Parses the file with the game code and returns the parse tree
Game parseGameFile(loc fileloc) {
  str s = readFile(fileloc);
  Game tree = parse(#Game, trim(s));
  checkGame(tree);
  return tree;
}

GameDef parseCheckGameModelFile(loc fileloc){
  GameDef game = parseGameModelFile(fileloc);
  list[SemanticError] errors= checkSemantics(game);
  if (  errors != []){
      throw("Errors in game file <errors>");
  }
  return game;
}

Game parseGame(str input) {
  Game tree = parse(#Game, trim(input));
  checkGame(tree);
  return tree;
}

GameDef parseGameModelFile(loc fileloc)
  = toModel(parseGameFile(fileloc));

GameDef parseGameModel(str input)
  = toModel(parseGame(input));

list[SemanticError] checkGameModelFile(loc fileloc)
  = checkSemantics(parseGameModelFile(fileloc));

list[SemanticError] checkGameModel(str input)
  = checkSemantics(parseGameModel(input));

Chest parseChest(str input) {
  Chest tree = parse(#Chest, trim(input));
  return tree;
}

Chest parseChestFile(loc fileloc) {
  str s = readFile(fileloc);
  return parse(#Chest, trim(s));
}


// checks required sections (board/actions/chest/players/flow)
void checkGame(Game g){
  nChest = 0;
  nBoard = 0;
  nActions = 0;
  nPlayers = 0;
  nFlow = 0;
  visit(g){
    case Chest _: nChest += 1;
    case Actions _: nActions += 1;
    case Board _: nBoard += 1;
    case Players _: nPlayers += 1;
    case Flow _: nFlow += 1;
  }
  if (nChest != 1) throw  nChest == 0 ? "No chest defined" :"Multiple chests defined" ;
  if (nActions != 1) throw nActions == 0 ? "No actions defined" :  "Multiple actions defined" ;
  if (nBoard != 1) throw nBoard == 0 ? "No board defined" : "Multiple boards defined" ;
  if (nPlayers != 1) throw nPlayers == 0 ? "No players defined" : "Multiple players blocks defined";
  if (nFlow != 1) throw nFlow == 0 ? "No flow defined" : "Multiple flows defined";
  return;
}
