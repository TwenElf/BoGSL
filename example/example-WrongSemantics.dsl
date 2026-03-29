game: {
  players: [
    id: white,
    pieces:{
      wP1: {
        type pawn
        direction: south
        initialPosition: {x: 0, y:1}
      },
      wP1: {
        type pawn
        direction: south
        initialPosition: {x: 1, y:1}
      }},
      id: black,
      pieces:
      {
      bP1: {
        type pawn
        direction: north
        initialPosition: {x:1, y:1}
      },
      bP2: {
        type pawn
        direction: north
        initialPosition: {x: 10, y:6}
      }
    }
  ],
  board: {width: 5, height:2},
  flow: {
    start: white,
    end: gameOver,
    machine: [
      state white: {
        moved -> black,
        noMoves -> white
      },
      state black: {
        moved -> white,
        noMoves -> black
      },
      state gameOver: {}
    ]
  },
  chest: [
    piece pawn: {
      move advance1: {forward 1},
      move firstMove: {forward 2} rule Movement firstMovePawn : location{ piece current } == location{ piece current initial },
      move captureL: {left 1, forward 1} rule Movement captureL: move piece current-> location{ opponent piece any},
      move captureR: {right 1, forward 1} rule Movement captureR: move piece current-> location{ opponent piece any},
      move enPassantCapture: {left 1, forward 1}
    }]
}
