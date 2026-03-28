game: {
  players: [
    id: white,
    pieces: {
      wP1: {
        type pawn
        direction: south
        initialPosition: {x: 0, y:1}
      },
      wP2: {
        type pawn
        direction: south
        initialPosition: {x: 1, y:1}
      },
      wP3: {
        type pawn
        direction: south
        initialPosition: {x: 2, y:1}
      },
      wP4: {
        type pawn
        direction: south
        initialPosition: {x: 3, y:1}
      },
      wP5: {
        type pawn
        direction: south
        initialPosition: {x: 4, y:1}
      },
      wP6: {
        type pawn
        direction: south
        initialPosition: {x: 5, y:1}
      },
      wP7: {
        type pawn
        direction: south
        initialPosition: {x: 6, y:1}
      },
      wP8: {
        type pawn
        direction: south
        initialPosition: {x: 7, y:1}
      },
      wBish1: {
        type bishop
        direction: south
        initialPosition: {x: 2, y:0}
      },
      wBish2: {
        type bishop
        direction: south
        initialPosition: {x: 5, y:0}
      },
      wKnight1: {
        type knight
        direction: south
        initialPosition: {x: 1, y:0}
      },
      wKnight2: {
        type knight
        direction: south
        initialPosition: {x: 6, y:0}
      },
      wRook1: {
        type rook
        direction: south
        initialPosition: {x: 0, y:0}
      },
      wRook2: {
        type rook
        direction: south
        initialPosition: {x: 7, y:0}
      },
      wK: {
        type king
        direction: south
        initialPosition: {x: 4, y:0}
      },
      wQ: {
        type king
        direction: south
        initialPosition: {x: 3, y:0}
      }
    },
    id: black,
    pieces: {
      bP1: {
        type pawn
        direction: north
        initialPosition: {x: 0, y:6}
      },
      bP2: {
        type pawn
        direction: north
        initialPosition: {x: 1, y:6}
      },
      bP3: {
        type pawn
        direction: north
        initialPosition: {x: 2, y:6}
      },
      bP4: {
        type pawn
        direction: north
        initialPosition: {x: 3, y:6}
      },
      bP5: {
        type pawn
        direction: north
        initialPosition: {x: 4, y:6}
      },
      bP6: {
        type pawn
        direction: north
        initialPosition: {x: 5, y:6}
      },
      bP7: {
        type pawn
        direction: north
        initialPosition: {x: 6, y:6}
      },
      bP8: {
        type pawn
        direction: north
        initialPosition: {x: 7, y:6}
      },
      bBish1: {
        type bishop
        direction: north
        initialPosition: {x: 2, y:7}
      },
      bBish2: {
        type bishop
        direction: north
        initialPosition: {x: 5, y:7}
      },
      bKnight1: {
        type knight
        direction: north
        initialPosition: {x: 1, y:7}
      },
      bKnight2: {
        type knight
        direction: north
        initialPosition: {x: 6, y:7}
      },
      bRook1: {
        type rook
        direction: north
        initialPosition: {x: 0, y:7}
      },
      bRook2: {
        type rook
        direction: north
        initialPosition: {x: 7, y:7}
      },
      bK: {
        type king
        direction: north
        initialPosition: {x: 4, y:7}
      },
      bQ: {
        type king
        direction: north
        initialPosition: {x: 3, y:7}
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
      move firstMove: {forward 2} rule Movement firstMovePawn : location{ piece current } == location{ piece current initial },
      move captureL: {left 1, forward 1} rule Movement captureL: move piece current-> location{ opponent piece any},
      move captureR: {right 1, forward 1} rule Movement captureR: move piece current-> location{ opponent piece any},
      move enPassantCapture: {left 1, forward 1}
    },
    piece king: {
      move stepF: {forward 1},
      move stepB: {backward 1},
      move stepL: {left 1},
      move stepR: {right 1}
    },
    piece bishop:{
      move left1: {forward 1, left 1},
      move left2: {forward 1, left 1,forward 1, left 1},
      move left3: {forward 1, left 1,forward 1, left 1,forward 1, left 1},
      move left4: {forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1},
      move left5: {forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1},
      move left6: {forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1},
      move left7: {forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1},
      move left8: {forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1},
      move right1: {forward 1, right 1},
      move right2: {forward 1, right 1,forward 1, right 1},
      move right3: {forward 1, right 1,forward 1, right 1,forward 1, right 1},
      move right4: {forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1},
      move right5: {forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1},
      move right6: {forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1},
      move right7: {forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1},
      move right8: {forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1},
      move left_back1: {backward 1, left 1},
      move left_back2: {backward 1, left 1,backward 1, left 1},
      move left_back3: {backward 1, left 1,backward 1, left 1,backward 1, left 1},
      move left_back4: {backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1},
      move left_back5: {backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1},
      move left_back6: {backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1},
      move left_back7: {backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1},
      move left_back8: {backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1},
      move right_back1: {backward 1, right 1},
      move right_back2: {backward 1, right 1,backward 1, right 1},
      move right_back3: {backward 1, right 1,backward 1, right 1,backward 1, right 1},
      move right_back4: {backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1},
      move right_back5: {backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1},
      move right_back6: {backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1},
      move right_back7: {backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1},
      move right_back8: {backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1}
    },
    piece rook: {
      move forward1: {forward 1},
      move forward2: {forward 2},
      move forward3: {forward 3},
      move forward4: {forward 4},
      move forward5: {forward 5},
      move forward6: {forward 6},
      move forward7: {forward 7},
      move forward8: {forward 8},
      move left1: {left 1},
      move left2: {left 2},
      move left3: {left 3},
      move left4: {left 4},
      move left5: {left 5},
      move left6: {left 6},
      move left7: {left 7},
      move left8: {left 8},
      move right1: {right 1},
      move right2: {right 2},
      move right3: {right 3},
      move right4: {right 4},
      move right5: {right 5},
      move right6: {right 6},
      move right7: {right 7},
      move right8: {right 8},
      move back1: {backward 1},
      move back2: {backward 2},
      move back3: {backward 3},
      move back4: {backward 4},
      move back5: {backward 5},
      move back6: {backward 6},
      move back7: {backward 7},
      move back8: {backward 8}
    },
    piece knight: {
      move forwardl: {forward 2, left 1},
      move forwardr: {forward 2, right 1},
      move leftup: {left 2, forward 1},
      move leftdown: {left 2, backward 1},
      move backwardl: {backward 2, left 1},
      move backwardr: {backward 2, right 1},
      move rightup: {right 2, forward 1},
      move rightdown: {right 2, backward 1}
    },
    piece queen:{
      move forward1: {forward 1},
      move forward2: {forward 2},
      move forward3: {forward 3},
      move forward4: {forward 4},
      move forward5: {forward 5},
      move forward6: {forward 6},
      move forward7: {forward 7},
      move forward8: {forward 8},
      move left1: {left 1},
      move left2: {left 2},
      move left3: {left 3},
      move left4: {left 4},
      move left5: {left 5},
      move left6: {left 6},
      move left7: {left 7},
      move left8: {left 8},
      move right1: {right 1},
      move right2: {right 2},
      move right3: {right 3},
      move right4: {right 4},
      move right5: {right 5},
      move right6: {right 6},
      move right7: {right 7},
      move right8: {right 8},
      move back1: {backward 1},
      move back2: {backward 2},
      move back3: {backward 3},
      move back4: {backward 4},
      move back5: {backward 5},
      move back6: {backward 6},
      move back7: {backward 7},
      move back8: {backward 8},
      move diag_left1: {forward 1, left 1},
      move diag_left2: {forward 2, left 2},
      move diag_left3: {forward 3, left 3},
      move diag_left4: {forward 4, left 4},
      move diag_left5: {forward 5, left 5},
      move diag_left6: {forward 6, left 6},
      move diag_left7: {forward 7, left 7},
      move diag_left8: {forward 8, left 8},
      move diag_right1: {forward 1, right 1},
      move diag_right2: {forward 2, right 2},
      move diag_right3: {forward 3, right 3},
      move diag_right4: {forward 4, right 4},
      move diag_right5: {forward 5, right 5},
      move diag_right6: {forward 6, right 6},
      move diag_right7: {forward 7, right 7},
      move diag_right8: {forward 8, right 8},
      move diag_left_back1: {backward 1, left 1},
      move diag_left_back2: {backward 2, left 2},
      move diag_left_back3: {backward 3, left 3},
      move diag_left_back4: {backward 4, left 4},
      move diag_left_back5: {backward 5, left 5},
      move diag_left_back6: {backward 6, left 6},
      move diag_left_back7: {backward 7, left 7},
      move diag_left_back8: {backward 8, left 8},
      move diag_right_back1: {backward 1, right 1},
      move diag_right_back2: {backward 2, right 2},
      move diag_right_back3: {backward 3, right 3},
      move diag_right_back4: {backward 4, right 4},
      move diag_right_back5: {backward 5, right 5},
      move diag_right_back6: {backward 6, right 6},
      move diag_right_back7: {backward 7, right 7},
      move diag_right_back8: {backward 8, right 8}

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
      rule Movement captureKing: move piece current -> location{piece id:wK},
      rule Movement promote:  move piece current  -> location{x: any, y: opposite boardedge}
  }
}
