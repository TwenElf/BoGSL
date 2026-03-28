game: {
  players: [
    id: white,
    pieces: {
      wP1: {
        type pawn
        direction: south
        initialPosition: {x: 1, y: 6}
      },
      wK: {
        type king
        direction: south
        initialPosition: {x: 4, y: 0}
      }
    },
    id: black,
    pieces: {
      bP1: {
        type pawn
        direction: north
        initialPosition: {x: 0, y: 3}
      },
      bK: {
        type king
        direction: north
        initialPosition: {x: 4, y: 7}
      }
    }
  ],
  board: {width: 8, height: 8},
  flow: {
    start: white,
    end: gameOver,
    machine: [
      state white: {
        moved -> black,
        noMoves -> gameOver
      },
      state black: {
        moved -> white,
        noMoves -> gameOver
      },
      state gameOver: {}
    ]
  },
  chest: [
    piece pawn: {
      move advance1: {forward 1},
      move firstMove: {forward 2},
      move captureL: {left 1, forward 1},
      move captureR: {right 1, forward 1},
      move enPassantCapture: {left 1, forward 1} rule Movement enPassant: move piece current-> location{ opponent piece any}
    },
    piece king: {
      move stepF: {forward 1},
      move stepB: {backward 1},
      move stepL: {left 1},
      move stepR: {right 1}
    }
  ],
  actions: [
    action: {ID: wP1, move: advance1},
    action: {ID: bP1, move: enPassantCapture},
    action: {ID: wK, move: stepB},
    action: {ID: bK, move: stepF}
  ],
  rules: {
      rule Movement captureOnMoveOver: move piece current-> other player piece any,
      rule Movement captureKing: move piece current -> location{piece wK},
      rule Movement promote:  move piece current  -> location{x: any, y: opposite boardedge}
  }
}
