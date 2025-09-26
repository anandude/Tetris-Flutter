import 'package:equatable/equatable.dart';

import 'tetromino_shape.dart';

class TetrominoInstance extends Equatable {
  const TetrominoInstance({
    required this.shape,
    required this.rotationIndex,
    required this.row,
    required this.column,
  });

  final TetrominoShape shape;
  final int rotationIndex;
  final int row;
  final int column;

  TetrominoInstance copyWith({
    int? rotationIndex,
    int? row,
    int? column,
  }) {
    return TetrominoInstance(
      shape: shape,
      rotationIndex: rotationIndex ?? this.rotationIndex,
      row: row ?? this.row,
      column: column ?? this.column,
    );
  }

  List<List<int>> get matrix => shape.rotationAt(rotationIndex);

  @override
  List<Object> get props => [shape, rotationIndex, row, column];
}

