module UI

import Gameplay;
import Model;
import salix::HTML;
import salix::App;
import salix::Index;

private data UIState
  = uiState(GameDef game, GameplayState gameplay, set[AvailableMove] hoveredMoves)
  ;

private data Msg
  = doMove(AvailableMove move)
  | mouseEnter(AvailableMove move)
  | mouseLeave(AvailableMove move)
  ;

alias UIApp = App[UIState];

// Create a new UI state
private UIState() init(GameDef game, GameplayState gameplay) {
  UIState initClosure() = uiState(game, gameplay, {});
  return initClosure;
}

// Update the state using a Msg as event
private UIState update(Msg msg, UIState state) {
  switch (msg) {
    case doMove(move): {
      state.gameplay.pieces[move.pieceId];
      state.gameplay = doAction(state.gameplay, state.game, actionDef(move.pieceId, move.moveId));
      state.gameplay.flowState = advanceFlow(state.game.flow, state.gameplay.flowState, "moved");
      state.hoveredMoves = {};
    }
    case mouseEnter(move): state.hoveredMoves += {move};
    case mouseLeave(move): state.hoveredMoves -= {move};
  };
  return state;
}

// Render the content of a cell
private void viewCell(UIState state, int x, int y) {
  set[tuple[int, int]] cellsHighlighted = {<move.targetX, move.targetY> | move <- state.hoveredMoves};
  set[str] piecesHighlighted = {move.pieceId | move <- state.hoveredMoves};
  map[str, PieceState] pieces = state.gameplay.pieces;
  div(classList(<"cell", true>, <"cell-hl", <x, y> in cellsHighlighted>), () {
    for (str name <- pieces) {
      if (pieces[name].x == x && pieces[name].y == y) {
        span(classList(<"piece-hl", name in piecesHighlighted>), name);
      }
    }
  });
}

// Render HTML using the state
private void view(UIState state) {
  BoardDef board = state.game.board;
  p("Flow state: <state.gameplay.flowState>");
  div(
    class("grid"),
    style(("--rows": "<board.height>", "--cols": "<board.width>")),
    () {
      for (int y <- [0..board.height], int x <- [0..board.width]) {
        viewCell(state, x, y);
      }
    }
  );
  ul(() {
    for (AvailableMove move <- currentPlayerAvailableMoves(state.game, state.gameplay)) {
      li(() {
        button(
          onClick(doMove(move)),
          onMouseEnter(mouseEnter(move)),
          onMouseLeave(mouseLeave(move)),
          "<move>"
        );
      });
    }
  });
}

// Start the UI
UIApp startUI(GameDef game, GameplayState gameplay) {
  str id = "BoGSL";
  SalixApp[UIState] app = makeApp(id, init(game, gameplay), withIndex("BoGSL", id, view, css = ["/style.css"]), update);
  return webApp(app, |cwd:///static|);
}
