import 'package:flutter/material.dart';

import '../models/board_cell.dart';
import '../models/game_board.dart';
import '../models/tetromino_instance.dart';

class BoardView extends StatefulWidget {
  const BoardView({
    super.key,
    required this.board,
    this.activePiece,
    this.highlightClearedLines,
  });

  final GameBoard board;
  final TetrominoInstance? activePiece;
  final Set<int>? highlightClearedLines;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightClearedLines?.isNotEmpty == true &&
        widget.highlightClearedLines != oldWidget.highlightClearedLines) {
      _sparkleController
        ..stop()
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cells = _buildCells();
    final highlightRows = widget.highlightClearedLines ?? const {};
    return AspectRatio(
      aspectRatio: widget.board.columns / widget.board.rows,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: widget.board.rows * widget.board.columns,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.board.columns,
        ),
        itemBuilder: (_, index) {
          final row = index ~/ widget.board.columns;
          final column = index % widget.board.columns;
          final cell = cells[row][column];
          final isHighlight = highlightRows.contains(row);
          return AnimatedBuilder(
            animation: _sparkleController,
            builder: (context, child) {
              final intensity = isHighlight
                  ? (1 - _sparkleController.value)
                  : 1.0;
              final color = cell.color;
              final displayColor = color == null
                  ? Colors.transparent
                  : Color.alphaBlend(
                      Colors.white.withValues(alpha: 0.4 * (1 - intensity)),
                      color,
                    );
              return AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26, width: 0.5),
                  color: displayColor,
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<List<BoardCell>> _buildCells() {
    final grid = widget.board.grid
        .map(
          (row) => row
              .map((cell) => BoardCell(color: cell.color))
              .toList(growable: false),
        )
        .toList(growable: false);
    final piece = widget.activePiece;
    if (piece == null) return grid;
    final matrix = piece.matrix;
    for (var r = 0; r < matrix.length; r++) {
      for (var c = 0; c < matrix[r].length; c++) {
        if (matrix[r][c] == 0) continue;
        final row = piece.row + r;
        final column = piece.column + c;
        if (widget.board.isInside(row, column)) {
          grid[row][column] = BoardCell(color: piece.shape.color);
        }
      }
    }
    return grid;
  }
}
