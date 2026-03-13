game: {
  players: [p1, p2],
  pieces: {
    p1Pawn: {
      type pawn
      direction: south
      initialPosition: {x: 0, y: 1}
    },
    p1Horse: {
      type horse
      direction: east
      initialPosition: {x: 1, y: 0}
    },
    p2Pawn: {
      type pawn
      direction: north
      initialPosition: {x: 0, y: 6}
    },
    p2Horse: {
      type horse
      direction: west
      initialPosition: {x: 1, y: 7}
    }
  },
  board: {width: 8, height: 8},
  chest: {
    piece pawn: {
      rule: pawnForwardOnly,
      move fwd: {forward 1},
      move fwd2: {forward 2}
    },
    piece horse: {
      rule: horseLMove,
      move fwdR: {forward 2, right 1},
      move rightDown: {backward 1, right 2},
      move none: {}
    }
  },
  actions: [
    action: {ID: p1Pawn, move: fwd},
    action: {ID: p1Horse, move: fwdR}
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
