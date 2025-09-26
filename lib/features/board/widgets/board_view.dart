import 'package:flutter/material.dart';

import '../models/board_cell.dart';
import '../models/game_board.dart';
import '../models/tetromino_instance.dart';

class BoardView extends StatelessWidget {
  const BoardView({
    super.key,
    required this.board,
    this.activePiece,
  });

  final GameBoard board;
  final TetrominoInstance? activePiece;

  @override
  Widget build(BuildContext context) {
    final cells = _buildCells();
    return AspectRatio(
      aspectRatio: board.columns / board.rows,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: board.rows * board.columns,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: board.columns,
        ),
        itemBuilder: (_, index) {
          final row = index ~/ board.columns;
          final column = index % board.columns;
          final cell = cells[row][column];
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 0.5),
              color: cell.color ?? Colors.transparent,
            ),
          );
        },
      ),
    );
  }

  List<List<BoardCell>> _buildCells() {
    final grid = board.grid
        .map(
          (row) => row
              .map((cell) => BoardCell(color: cell.color))
              .toList(growable: false),
        )
        .toList(growable: false);
    final piece = activePiece;
    if (piece == null) return grid;
    final matrix = piece.matrix;
    for (var r = 0; r < matrix.length; r++) {
      for (var c = 0; c < matrix[r].length; c++) {
        if (matrix[r][c] == 0) continue;
        final row = piece.row + r;
        final column = piece.column + c;
        if (board.isInside(row, column)) {
          grid[row][column] = BoardCell(color: piece.shape.color);
        }
      }
    }
    return grid;
  }
}

