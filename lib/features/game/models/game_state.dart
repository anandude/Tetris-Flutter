import 'package:equatable/equatable.dart';

import '../../board/models/game_board.dart';
import '../../board/models/tetromino_instance.dart';
import 'game_stats.dart';

enum GamePhase { initializing, running, paused, gameOver }

class GameState extends Equatable {
  const GameState({
    required this.board,
    required this.activePiece,
    required this.nextQueue,
    required this.stats,
    required this.phase,
    required this.dropInterval,
  });

  factory GameState.initial(GameBoard board) {
    return GameState(
      board: board,
      activePiece: null,
      nextQueue: const [],
      stats: const GameStats(),
      phase: GamePhase.initializing,
      dropInterval: board.rows * 40,
    );
  }

  final GameBoard board;
  final TetrominoInstance? activePiece;
  final List<TetrominoInstance> nextQueue;
  final GameStats stats;
  final GamePhase phase;
  final int dropInterval;

  GameState copyWith({
    GameBoard? board,
    TetrominoInstance? activePiece,
    List<TetrominoInstance>? nextQueue,
    GameStats? stats,
    GamePhase? phase,
    int? dropInterval,
  }) {
    return GameState(
      board: board ?? this.board,
      activePiece: activePiece ?? this.activePiece,
      nextQueue: nextQueue ?? this.nextQueue,
      stats: stats ?? this.stats,
      phase: phase ?? this.phase,
      dropInterval: dropInterval ?? this.dropInterval,
    );
  }

  @override
  List<Object?> get props => [
        board,
        activePiece,
        nextQueue,
        stats,
        phase,
        dropInterval,
      ];
}

