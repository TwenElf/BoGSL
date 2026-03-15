module UI

import Gameplay;
import Model;
import salix::HTML;
import salix::App;
import salix::Index;

private data UIState
  = uiState(GameDef game, GameplayState gameplay)
  ;

private data Msg
  = doMove(AvailableMove move);

alias UIApp = App[UIState];

// Create a new UI state
private UIState() init(GameDef game, GameplayState gameplay) {
  UIState initClosure() = uiState(game, gameplay);
  return initClosure;
}

// Update the state using a Msg as event
private UIState update(Msg msg, UIState state) {
  switch (msg) {
    case doMove(move): {
      state.gameplay.pieces[move.pieceId];
      state.gameplay = doAction(state.gameplay, state.game, actionDef(move.pieceId, move.moveId));
      state.gameplay.flowState = advanceFlow(state.game.flow, state.gameplay.flowState, "moved");
    }
  };
  return state;
}

// Render the content of a cell
private void viewCell(UIState state, int x, int y) {
  map[str, PieceState] pieces = state.gameplay.pieces;
  for (str name <- pieces) {
    if (pieces[name].x == x && pieces[name].y == y) {
      span(name);
    }
  }
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
        div(class("cell"), () {
          viewCell(state, x, y);
        });
      }
    }
  );
  ul(() {
    for (AvailableMove move <- currentPlayerAvailableMoves(state.game, state.gameplay)) {
      li(() {
        button(onClick(doMove(move)), "<move>");
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
