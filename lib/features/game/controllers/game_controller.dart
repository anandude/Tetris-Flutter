import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../core/game_config.dart';
import '../../board/models/game_board.dart';
import '../../board/models/tetromino_definitions.dart';
import '../../board/models/tetromino_instance.dart';
import '../../board/models/tetromino_shape.dart';
import '../models/game_state.dart';
import '../models/game_stats.dart';

class GameController extends ChangeNotifier {
  GameController({
    required GameConfig config,
  })  : _config = config,
        _board = GameBoard.fromConfig(config),
        _random = Random();

  final GameConfig _config;
  GameBoard _board;
  TetrominoInstance? _activePiece;
  final Queue<TetrominoInstance> _nextPieces = Queue();
  final Random _random;
  GameStats _stats = const GameStats();
  GamePhase _phase = GamePhase.initializing;
  Timer? _timer;

  GameBoard get board => _board;
  TetrominoInstance? get activePiece => _activePiece;
  List<TetrominoInstance> get nextQueue => List.unmodifiable(_nextPieces);
  GameStats get stats => _stats;
  GamePhase get phase => _phase;
  int get dropInterval => _currentDropInterval;

  int get _currentDropInterval {
    final minInterval = _config.minimumDropIntervalMs;
    final interval = (_config.initialDropIntervalMs *
            pow(_config.speedIncreaseFactor, (_stats.level - 1)))
        .round();
    final num clamped = interval.clamp(minInterval, _config.initialDropIntervalMs);
    return clamped.toInt();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void start() {
    _beginNewGame();
  }

  void pause() {
    if (_phase != GamePhase.running) return;
    _phase = GamePhase.paused;
    _timer?.cancel();
    notifyListeners();
  }

  void resume() {
    if (_phase != GamePhase.paused) return;
    _phase = GamePhase.running;
    _scheduleTick();
    notifyListeners();
  }

  void restart() => _beginNewGame();

  void stop() {
    _timer?.cancel();
    _phase = GamePhase.gameOver;
    notifyListeners();
  }

  void moveLeft() => _tryShift(columnDelta: -1);
  void moveRight() => _tryShift(columnDelta: 1);
  void softDrop() => _tryShift(rowDelta: 1);
  void hardDrop() {
    if (_phase != GamePhase.running || _activePiece == null) return;
    while (_tryShift(rowDelta: 1, notify: false)) {
      // drop until collision
    }
    _lockActivePiece();
  }

  void rotate() {
    if (_phase != GamePhase.running || _activePiece == null) return;
    final piece = _activePiece!;
    final rotated = piece.copyWith(rotationIndex: piece.rotationIndex + 1);
    if (_board.canPlace(rotated)) {
      _activePiece = rotated;
      notifyListeners();
    }
  }

  void _scheduleTick() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _currentDropInterval), (_) {
      if (_phase != GamePhase.running) return;
      final moved = _tryShift(rowDelta: 1, notify: false);
      if (!moved) {
        _lockActivePiece();
      } else {
        notifyListeners();
      }
    });
  }

  bool _tryShift({int rowDelta = 0, int columnDelta = 0, bool notify = true}) {
    if (_phase != GamePhase.running || _activePiece == null) {
      return false;
    }
    final piece = _activePiece!;
    final shifted = piece.copyWith(
      row: piece.row + rowDelta,
      column: piece.column + columnDelta,
    );
    if (_board.canPlace(shifted)) {
      _activePiece = shifted;
      if (notify) notifyListeners();
      return true;
    }
    return false;
  }

  void _lockActivePiece() {
    if (_activePiece == null) return;
    final lockResult = _board.lockPiece(_activePiece!);
    _board = lockResult.board;
    _updateStats(lockResult.clearedLines);
    _spawnNextPiece();
    if (!_board.canPlace(_activePiece!)) {
      _phase = GamePhase.gameOver;
      _timer?.cancel();
    }
    notifyListeners();
  }

  void _updateStats(int clearedLines) {
    if (clearedLines == 0) return;
    final newLines = _stats.linesCleared + clearedLines;
    final newLevel = 1 + newLines ~/ 10;
    final scoreGain = _scoreForLines(clearedLines) * newLevel;
    _stats = _stats.copyWith(
      linesCleared: newLines,
      level: newLevel,
      score: _stats.score + scoreGain,
    );
  }

  int _scoreForLines(int clearedLines) {
    switch (clearedLines) {
      case 1:
        return 100;
      case 2:
        return 300;
      case 3:
        return 500;
      case 4:
        return 800;
      default:
        return clearedLines * 200;
    }
  }

  void _spawnNextPiece() {
    if (_nextPieces.isEmpty) {
      _nextPieces.addAll(_generatePieces(3));
    }
    _activePiece = _nextPieces.removeFirst();
    while (_nextPieces.length < 3) {
      _nextPieces.addAll(_generatePieces(3));
    }
  }

  Iterable<TetrominoInstance> _generatePieces(int count) sync* {
    final shapes = TetrominoType.values.toList()..shuffle(_random);
    for (var i = 0; i < count; i++) {
      final shape = tetrominoes[shapes[i % shapes.length]]!;
      yield TetrominoInstance(
        shape: shape,
        rotationIndex: 0,
        row: 0,
        column: (_config.columns ~/ 2) - (shape.rotationAt(0)[0].length ~/ 2),
      );
    }
  }

  void _beginNewGame() {
    _timer?.cancel();
    _phase = GamePhase.running;
    _stats = const GameStats();
    _board = GameBoard.fromConfig(_config);
    _activePiece = null;
    _nextPieces
      ..clear()
      ..addAll(_generatePieces(3));
    _spawnNextPiece();
    _scheduleTick();
    notifyListeners();
  }

  static Widget scope({required Widget child}) {
    return ChangeNotifierProvider<GameController>(
      create: (context) => GameController(
        config: Provider.of<GameConfig>(context, listen: false),
      )..start(),
      child: child,
    );
  }
}

