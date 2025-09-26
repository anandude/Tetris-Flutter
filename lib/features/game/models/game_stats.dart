import 'package:equatable/equatable.dart';

class GameStats extends Equatable {
  const GameStats({
    this.score = 0,
    this.level = 1,
    this.linesCleared = 0,
    this.combo = 0,
    this.bestScore = 0,
    this.bestScorePersisted = false,
  });

  final int score;
  final int level;
  final int linesCleared;
  final int combo;
  final int bestScore;
  final bool bestScorePersisted;

  GameStats copyWith({
    int? score,
    int? level,
    int? linesCleared,
    int? combo,
    int? bestScore,
    bool? bestScorePersisted,
  }) {
    return GameStats(
      score: score ?? this.score,
      level: level ?? this.level,
      linesCleared: linesCleared ?? this.linesCleared,
      combo: combo ?? this.combo,
      bestScore: bestScore ?? this.bestScore,
      bestScorePersisted: bestScorePersisted ?? this.bestScorePersisted,
    );
  }

  @override
  List<Object> get props => [
    score,
    level,
    linesCleared,
    combo,
    bestScore,
    bestScorePersisted,
  ];
}
