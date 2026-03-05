module Checks

import List;
import Map;
import Model;
import Set;

data SemanticError
  = DuplicatePiece(str pieceId)
  | MissingPieceDirection(str pieceId)
  | MultiplePieceDirections(str pieceId, int count)
  | DuplicateMove(str pieceId, str moveId)
  | UnknownActionPiece(str pieceId)
  | UnknownActionMove(str pieceId, str moveId)
  ;

list[SemanticError] checkSemantics(GameDef game) {
  list[SemanticError] errors = [];

  switch (game) {
    case gameDef(_, list[PieceDef] pieces, list[ActionDef] actions): {
      set[str] pieceIds = {};
      map[str, set[str]] movesByPiece = ();

      for (piece <- pieces) {
        switch (piece) {
          case pieceDef(str pieceId, list[Facing] directions, list[MoveDef] moves): {
            if (pieceId in pieceIds) {
              errors += [DuplicatePiece(pieceId)];
            } else {
              pieceIds += {pieceId};
            }

            if (size(directions) == 0) {
              errors += [MissingPieceDirection(pieceId)];
            } else if (size(directions) > 1) {
              errors += [MultiplePieceDirections(pieceId, size(directions))];
            }

            set[str] moveIds = {};
            for (move <- moves) {
              switch (move) {
                case moveDef(str moveId, _): {
                  if (moveId in moveIds) {
                    errors += [DuplicateMove(pieceId, moveId)];
                  } else {
                    moveIds += {moveId};
                  }
                }
              }
            }

            movesByPiece[pieceId] = moveIds;
          }
        }
      }

      for (action <- actions) {
        switch (action) {
          case actionDef(str pieceId, str moveId): {
            if (!(pieceId in pieceIds)) {
              errors += [UnknownActionPiece(pieceId)];
            } else if (!(moveId in movesByPiece[pieceId])) {
              errors += [UnknownActionMove(pieceId, moveId)];
            }
          }
        }
      }
    }
  }

  return errors;
}
