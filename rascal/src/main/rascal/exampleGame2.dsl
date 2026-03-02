game : {
    board: {width: 8, height: 8},
    chest: {
        piece pawn: {
            direction : south,
            move fwd : {forward 1},
            move fwd2 : {forward 2}
            },
        piece horse: {
            direction : east,
            move fwdR : {forward 2, right 1},
            move rightDown : {backward 1, right 2},
            move none: {}
            }
        },
        actions:[
            action: {ID: pawn, move: fwd1},
            action: {ID: horse, move: fwdR}
        ]
        
    
}