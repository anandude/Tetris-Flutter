import 'dart:ui';

import 'package:equatable/equatable.dart';

enum TetrominoType { i, o, t, s, z, j, l }

class TetrominoShape extends Equatable {
  const TetrominoShape({
    required this.type,
    required this.rotations,
    required this.color,
  });

  final TetrominoType type;
  final List<List<List<int>>> rotations;
  final Color color;

  List<List<int>> rotationAt(int index) => rotations[index % rotations.length];

  @override
  List<Object> get props => [type, rotations, color];
}

