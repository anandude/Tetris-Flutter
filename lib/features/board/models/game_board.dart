import 'package:equatable/equatable.dart';

import '../../../core/game_config.dart';
import 'board_cell.dart';
import 'tetromino_instance.dart';

class LockResult {
  const LockResult({
    required this.board,
    required this.clearedLines,
    required this.clearedLineIndexes,
  });

  final GameBoard board;
  final int clearedLines;
  final Set<int> clearedLineIndexes;
}

class GameBoard extends Equatable {
  GameBoard({
    required this.rows,
    required this.columns,
    List<List<BoardCell>>? grid,
  }) : grid = grid ?? _createEmptyGrid(rows, columns);

  factory GameBoard.fromConfig(GameConfig config) {
    return GameBoard(rows: config.rows, columns: config.columns);
  }

  final int rows;
  final int columns;
  final List<List<BoardCell>> grid;

  static List<List<BoardCell>> _createEmptyGrid(int rows, int columns) {
    return List.generate(
      rows,
      (_) => List.generate(columns, (_) => const BoardCell()),
    );
  }

  BoardCell cellAt(int row, int column) => grid[row][column];

  bool isInside(int row, int column) {
    return row >= 0 && row < rows && column >= 0 && column < columns;
  }

  bool canPlace(TetrominoInstance piece) {
    final matrix = piece.matrix;
    for (var r = 0; r < matrix.length; r++) {
      for (var c = 0; c < matrix[r].length; c++) {
        if (matrix[r][c] == 0) continue;
        final boardRow = piece.row + r;
        final boardColumn = piece.column + c;
        if (!isInside(boardRow, boardColumn)) {
          return false;
        }
        if (!cellAt(boardRow, boardColumn).isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  LockResult lockPiece(TetrominoInstance piece) {
    final newGrid = _copyGrid();
    final matrix = piece.matrix;
    for (var r = 0; r < matrix.length; r++) {
      for (var c = 0; c < matrix[r].length; c++) {
        if (matrix[r][c] == 0) continue;
        final row = piece.row + r;
        final column = piece.column + c;
        if (isInside(row, column)) {
          newGrid[row][column] = BoardCell(color: piece.shape.color);
        }
      }
    }
    return _clearCompletedLines(newGrid);
  }

  LockResult _clearCompletedLines(List<List<BoardCell>> currentGrid) {
    final newGrid = <List<BoardCell>>[];
    var clearedLines = 0;

    for (final row in currentGrid) {
      final filled = row.every((cell) => !cell.isEmpty);
      if (filled) {
        clearedLines++;
        continue;
      }
      newGrid.add(List.from(row));
    }

    while (newGrid.length < rows) {
      newGrid.insert(0, List.generate(columns, (_) => const BoardCell()));
    }

    final clearedIndexes = <int>{};
    if (clearedLines > 0) {
      var nextIndex = rows - 1;
      for (var row = rows - 1; row >= 0; row--) {
        final originalRow = currentGrid[row];
        final isFilled = originalRow.every((cell) => !cell.isEmpty);
        if (isFilled) {
          clearedIndexes.add(nextIndex);
        }
        nextIndex--;
      }
    }

    return LockResult(
      board: GameBoard(rows: rows, columns: columns, grid: newGrid),
      clearedLines: clearedLines,
      clearedLineIndexes: clearedIndexes,
    );
  }

  List<List<BoardCell>> _copyGrid() {
    return [
      for (final row in grid)
        [for (final cell in row) BoardCell(color: cell.color)],
    ];
  }

  @override
  List<Object> get props => [rows, columns, grid];
}
