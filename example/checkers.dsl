game : {
    board: {width: 8, height: 8},
    players: [
        id: white,
        pieces: {wR1: {type regular direction: south initialPosition: {x: 1, y:0}},
                wR2: {type regular direction: south initialPosition: {x: 3, y:0}},
                wR3: {type regular direction: south initialPosition: {x: 5, y:0}},
                wR4: {type regular direction: south initialPosition: {x: 7, y:0}},
                wR5: {type regular direction: south initialPosition: {x: 1, y:2}},
                wR6: {type regular direction: south initialPosition: {x: 3, y:2}},
                wR7: {type regular direction: south initialPosition: {x: 5, y:2}},
                wR8: {type regular direction: south initialPosition: {x: 7, y:2}},
                wR9: {type regular direction: south initialPosition: {x: 0, y:1}},
                wR10: {type regular direction: south initialPosition: {x: 2, y:1}},
                wR11: {type regular direction: south initialPosition: {x: 4, y:1}},
                wR12: {type regular direction: south initialPosition: {x: 6, y:1}}
                },
        id: red,
        pieces: {rR1: {type regular direction: north initialPosition: {x: 0, y:5}},
                rR2: {type regular direction: north initialPosition: {x: 2, y:5}},
                rR3: {type regular direction: north initialPosition: {x: 4, y:5}},
                rR4: {type regular direction: north initialPosition: {x: 6, y:5}},
                rR5: {type regular direction: north initialPosition: {x: 0, y:7}},
                rR6: {type regular direction: north initialPosition: {x: 2, y:7}},
                rR7: {type regular direction: north initialPosition: {x: 4, y:7}},
                rR8: {type regular direction: north initialPosition: {x: 6, y:7}},
                rR9: {type regular direction: north initialPosition: {x: 1, y:6}},
                rR10: {type regular direction: north initialPosition: {x: 3, y:6}},
                rR11: {type regular direction: north initialPosition: {x: 5, y:6}},
                rR12: {type regular direction: north initialPosition: {x: 7, y:6}}
                }
    ],
    flow: {
        start: white,
        end: gameOver,
        machine: [
        state white: {
            moved -> red,
            noMoves -> gameOver
        },
        state red: {
            moved -> white,
            noMoves -> gameOver
        },
        state gameOver: {}
        ]
    },
    chest: [
        piece regular: {
            move left1: {forward 1, left 1},
            move left3: {forward 1, left 1,forward 1, left 1,forward 1, left 1},
            move left5: {forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1},
            move left7: {forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1},
            move right1: {forward 1, right 1},
            move right3: {forward 1, right 1,forward 1, right 1,forward 1, right 1},
            move right5: {forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1},
            move right7: {forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1}
        },
        piece king: {
            move left1: {forward 1, left 1},
            move left3: {forward 1, left 1,forward 1, left 1,forward 1, left 1},
            move left5: {forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1},
            move left7: {forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1,forward 1, left 1},
            move right1: {forward 1, right 1},
            move right3: {forward 1, right 1,forward 1, right 1,forward 1, right 1},
            move right5: {forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1},
            move right7: {forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1,forward 1, right 1},
            move left_back1: {backward 1, left 1},
            move left_back3: {backward 1, left 1,backward 1, left 1,backward 1, left 1},
            move left_back5: {backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1},
            move left_back7: {backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1,backward 1, left 1},
            move right_back1: {backward 1, right 1},
            move right_back3: {backward 1, right 1,backward 1, right 1,backward 1, right 1},
            move right_back5: {backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1},
            move right_back7: {backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1,backward 1, right 1}
        }
    ],
    rules: {
        rule Movement promote:  move piece current  -> location{x: any, y: opposite boardedge}
    }

}
