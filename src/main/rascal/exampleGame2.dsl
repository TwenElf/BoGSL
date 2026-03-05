game: {
  players: [p1, p2],
  board: {width: 8, height: 8},
  chest: {
    piece pawn: {
      direction: south,
      rule: pawnForwardOnly,
      move fwd: {forward 1},
      move fwd2: {forward 2}
    },
    piece horse: {
      direction: east,
      rule: horseLMove,
      move fwdR: {forward 2, right 1},
      move rightDown: {backward 1, right 2},
      move none: {}
    }
  },
  actions: [
    action: {ID: pawn, move: fwd},
    action: {ID: horse, move: fwdR}
  ],
  flow: {
    start: playerTurn,
    end: gameOver,
    machine: {
      state playerTurn: {
        p1Move -> resolveTurn,
        p2Move -> resolveTurn
      },
      state resolveTurn: {
        nextP1 -> playerTurn,
        nextP2 -> playerTurn,
        gameEnds -> gameOver
      },
      state gameOver: {}
    }
  },
  rule: mustMoveInBounds,
  rule: oneActionPerTurn
}
