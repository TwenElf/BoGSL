game: {
  players: {
    id: white,
    pieces: {
      whitePawnA: {
        type pawn
        direction: south
        initialPosition: {x: 0, y: 1}
      },
      whiteKing: {
        type king
        direction: south
        initialPosition: {x: 4, y: 0}
      }
    },
    id: black,
    pieces: {
      blackPawnA: {
        type pawn
        direction: north
        initialPosition: {x: 0, y: 6}
      },
      blackKing: {
        type king
        direction: north
        initialPosition: {x: 4, y: 7}
      }
    }
  },
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
      rule: enPassant,
      move advance1: {forward 1},
      move firstMove: {forward 2},
      move captureL: {left 1, forward 1},
      move captureR: {right 1, forward 1},
      move enPassantCapture: {left 1, forward 1}
    },
    piece king: {
      move stepF: {forward 1},
      move stepB: {backward 1},
      move stepL: {left 1},
      move stepR: {right 1}
    }
  },
  actions: [
    action: {ID: whitePawnA, move: advance1},
    action: {ID: blackPawnA, move: enPassantCapture},
    action: {ID: whiteKing, move: stepB}
  ]
}
