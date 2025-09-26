import 'package:flutter/material.dart';

import 'tetromino_shape.dart';

const Map<TetrominoType, TetrominoShape> tetrominoes = {
  TetrominoType.i: TetrominoShape(
    type: TetrominoType.i,
    color: Color(0xFF35C4F2),
    rotations: [
      [
        [0, 0, 0, 0],
        [1, 1, 1, 1],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      [
        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
      ],
    ],
  ),
  TetrominoType.o: TetrominoShape(
    type: TetrominoType.o,
    color: Color(0xFFF7D046),
    rotations: [
      [
        [1, 1],
        [1, 1],
      ],
    ],
  ),
  TetrominoType.t: TetrominoShape(
    type: TetrominoType.t,
    color: Color(0xFF9B59B6),
    rotations: [
      [
        [0, 1, 0],
        [1, 1, 1],
        [0, 0, 0],
      ],
      [
        [0, 1, 0],
        [0, 1, 1],
        [0, 1, 0],
      ],
      [
        [0, 0, 0],
        [1, 1, 1],
        [0, 1, 0],
      ],
      [
        [0, 1, 0],
        [1, 1, 0],
        [0, 1, 0],
      ],
    ],
  ),
  TetrominoType.s: TetrominoShape(
    type: TetrominoType.s,
    color: Color(0xFF2ECC71),
    rotations: [
      [
        [0, 1, 1],
        [1, 1, 0],
        [0, 0, 0],
      ],
      [
        [0, 1, 0],
        [0, 1, 1],
        [0, 0, 1],
      ],
    ],
  ),
  TetrominoType.z: TetrominoShape(
    type: TetrominoType.z,
    color: Color(0xFFE74C3C),
    rotations: [
      [
        [1, 1, 0],
        [0, 1, 1],
        [0, 0, 0],
      ],
      [
        [0, 0, 1],
        [0, 1, 1],
        [0, 1, 0],
      ],
    ],
  ),
  TetrominoType.j: TetrominoShape(
    type: TetrominoType.j,
    color: Color(0xFF2980B9),
    rotations: [
      [
        [1, 0, 0],
        [1, 1, 1],
        [0, 0, 0],
      ],
      [
        [0, 1, 1],
        [0, 1, 0],
        [0, 1, 0],
      ],
      [
        [0, 0, 0],
        [1, 1, 1],
        [0, 0, 1],
      ],
      [
        [0, 1, 0],
        [0, 1, 0],
        [1, 1, 0],
      ],
    ],
  ),
  TetrominoType.l: TetrominoShape(
    type: TetrominoType.l,
    color: Color(0xFFF39C12),
    rotations: [
      [
        [0, 0, 1],
        [1, 1, 1],
        [0, 0, 0],
      ],
      [
        [0, 1, 0],
        [0, 1, 0],
        [0, 1, 1],
      ],
      [
        [0, 0, 0],
        [1, 1, 1],
        [1, 0, 0],
      ],
      [
        [1, 1, 0],
        [0, 1, 0],
        [0, 1, 0],
      ],
    ],
  ),
};

List<TetrominoShape> get allTetrominoShapes => tetrominoes.values.toList();

