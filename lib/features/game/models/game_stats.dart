import 'package:equatable/equatable.dart';

class GameStats extends Equatable {
  const GameStats({
    this.score = 0,
    this.level = 1,
    this.linesCleared = 0,
  });

  final int score;
  final int level;
  final int linesCleared;

  GameStats copyWith({
    int? score,
    int? level,
    int? linesCleared,
  }) {
    return GameStats(
      score: score ?? this.score,
      level: level ?? this.level,
      linesCleared: linesCleared ?? this.linesCleared,
    );
  }

  @override
  List<Object> get props => [score, level, linesCleared];
}

