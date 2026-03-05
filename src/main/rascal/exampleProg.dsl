piece pawn: {
    move fwd : {forward 1},
    move fwd2 : {forward 2},
    move captureL : {forward 1, left 1},
    move captureR : {forward 1, right 1}
};
piece horse: {
    move fwdR : {forward 2, right 1},
    move fwdL : {forward 2, left 1},
    move rightUp : {forward 1, right 2},
    move rightDown : {backward 1, right 2}
}