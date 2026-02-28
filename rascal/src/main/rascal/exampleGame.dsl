game : {
    chest: 
        piece pawn: {
            move fwd : {forward 1},
            move fwd2 : {forward 2}
        };
        piece horse: {
            move fwdR : {forward 2, right 1},
            move rightDown : {backward 1, right 2}
        },
        actions:{
            action: {ID: pawn, move: fwd1},
            action: {ID: horse, move: fwdR}
        }
        
    
}