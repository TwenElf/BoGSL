game: {
  players: [white, black],
  board: {width: 8, height: 8},
  flow: {
    start: whiteTurn,
    end: gameOver,
    machine: {
      state whiteTurn: {
        moveWhite -> blackTurn,
        whiteResigns -> gameOver
      },
      state blackTurn: {
        moveBlack -> whiteTurn,
        blackResigns -> gameOver,
        checkmate -> gameOver
      },
      state gameOver: {}
    }
  },
  rule: checkmateEndsGame,
  chest: {
    piece pawn: {
      direction: south,
      rule: enPassant,
      move advance1: {forward 1},
      move firstMove: {forward 2},
      move captureL: {left 1, forward 1},
      move captureR: {right 1, forward 1},
      move enPassantCapture: {left 1, forward 1}
    },
    piece king: {
      direction: north,
      move stepF: {forward 1},
      move stepB: {backward 1},
      move stepL: {left 1},
      move stepR: {right 1}
    }
  },
  actions: [
    action: {ID: pawn, move: advance1},
    action: {ID: pawn, move: enPassantCapture},
    action: {ID: king, move: stepB}
  ]
}
