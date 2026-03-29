game: {
  board: {width: 4, height: 4},
  players: [
    id: p1,
    pieces: {
      wKing: {
        type king
        direction: south
        initialPosition: {x: 0, y: 0}
      },
      wP1: {
        type pawn
        direction: south
        initialPosition: {x: 1, y: 0}
      },
      wP2: {
        type pawn
        direction: south
        initialPosition: {x: 2, y: 0}
      },
      wP3: {
        type pawn
        direction: south
        initialPosition: {x: 3, y: 0}
      }
    },
    id: p2,
    pieces: {
      bKing: {
        type king
        direction: north
        initialPosition: {x: 3, y: 3}
      },
      bP1: {
        type pawn
        direction: north
        initialPosition: {x: 0, y: 3}
      },
      bP2: {
        type pawn
        direction: north
        initialPosition: {x: 1, y: 3}
      },
      bP3: {
        type pawn
        direction: north
        initialPosition: {x: 2, y: 3}
      }
    }
  ],
  chest: [
    piece pawn: {
      move ahead: {forward 1},
      move diagLeft: {forward 1, left 1},
      move diagRight: {forward 1, right 1},
      move superjump: {forward 2} rule Movement capturable:
        (move piece current -> location {piece id: wKing})
        || (move piece current -> location {piece id: bKing})
    },
    piece king: {
      move ahead: {forward 1},
      move diagLeft: {forward 1, left 1},
      move diagRight: {forward 1, right 1}
    }
  ],
  flow: {
    start: p1,
    end: gameOver,
    machine: [
      state p1: {
        moved -> p2,
        noMoves -> gameOver
      },
      state p2: {
        moved -> p1,
        noMoves -> gameOver
      },
      state gameOver: {}
    ]
  }
}
