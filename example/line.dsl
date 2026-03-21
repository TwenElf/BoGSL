game: {
  players: [
    id: p1,
    pieces: {
      p: {
        type player
        direction: south
        initialPosition: {x: 0, y: 0}
      }
    }
  ],
  board: {width: 1, height: 5},
  chest: [
    piece player: {
      move fwd: {forward 1}
    }
  ],
  actions: [
    action: {ID: p, move: fwd}
  ],
  flow: {
    start: p1,
    end: gameOver,
    machine: [
      state p1: {
        moved -> p1,
        noMoves -> gameOver
      },
      state gameOver: {}
    ]
  }
}
