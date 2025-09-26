import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/game_config.dart';
import '../../board/models/game_board.dart';
import '../../board/models/tetromino_definitions.dart';
import '../../board/models/tetromino_instance.dart';
import '../../board/models/tetromino_shape.dart';
import '../models/game_state.dart';
import '../models/game_stats.dart';

class GameController extends ChangeNotifier {
  GameController({required GameConfig config, SharedPreferences? preferences})
    : _config = config,
      _board = GameBoard.fromConfig(config),
      _random = Random(),
      _preferences = preferences;

  final GameConfig _config;
  GameBoard _board;
  TetrominoInstance? _activePiece;
  final Queue<TetrominoInstance> _nextPieces = Queue();
  final Random _random;
  GameStats _stats = const GameStats();
  GamePhase _phase = GamePhase.initializing;
  Timer? _timer;
  SharedPreferences? _preferences;
  Set<int> _clearedRows = const {};
  int _lineClearFlashToken = 0;
  bool _landingFlashActive = false;
  int _landingFlashToken = 0;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  GameBoard get board => _board;
  TetrominoInstance? get activePiece => _activePiece;
  List<TetrominoInstance> get nextQueue => List.unmodifiable(_nextPieces);
  GameStats get stats => _stats;
  GamePhase get phase => _phase;
  int get dropInterval => _currentDropInterval;
  Set<int> get highlightRows => _clearedRows;
  bool get landingFlashActive => _landingFlashActive;
  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  int get _currentDropInterval {
    final minInterval = _config.minimumDropIntervalMs;
    final interval =
        (_config.initialDropIntervalMs *
                pow(_config.speedIncreaseFactor, (_stats.level - 1)))
            .round();
    final num clamped = interval.clamp(
      minInterval,
      _config.initialDropIntervalMs,
    );
    return clamped.toInt();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> start() async {
    _preferences ??= await SharedPreferences.getInstance();
    final bestScore = _preferences?.getInt(_bestScoreKey) ?? 0;
    _stats = _stats.copyWith(bestScore: bestScore, bestScorePersisted: true);
    _soundEnabled = _preferences?.getBool(_soundKey) ?? true;
    _hapticsEnabled = _preferences?.getBool(_hapticsKey) ?? true;
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
    _updateBestScore();
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
    _lockActivePiece(triggerHardDrop: true);
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

  void _lockActivePiece({bool triggerHardDrop = false}) {
    if (_activePiece == null) return;
    final lockResult = _board.lockPiece(_activePiece!);
    _board = lockResult.board;
    if (lockResult.clearedLines > 0) {
      _triggerLineClearFlash(lockResult.clearedLineIndexes);
    } else {
      _clearLineFlash();
    }
    _triggerLandingFlash();
    _updateStats(lockResult.clearedLines);
    _spawnNextPiece();
    if (!_board.canPlace(_activePiece!)) {
      _phase = GamePhase.gameOver;
      _timer?.cancel();
      _updateBestScore();
    }
    notifyListeners();
  }

  void _updateStats(int clearedLines) {
    if (clearedLines == 0) {
      if (_stats.combo != 0) {
        _stats = _stats.copyWith(combo: 0);
      }
      return;
    }

    final newLines = _stats.linesCleared + clearedLines;
    final newCombo = _stats.combo + 1;
    final newLevel = 1 + newLines ~/ 10;
    final scoreGain = _scoreForLines(clearedLines, combo: newCombo) * newLevel;
    _stats = _stats.copyWith(
      linesCleared: newLines,
      level: newLevel,
      score: _stats.score + scoreGain,
      combo: newCombo,
    );

    if (_stats.score > _stats.bestScore) {
      _stats = _stats.copyWith(bestScore: _stats.score);
    }
  }

  int _scoreForLines(int clearedLines, {required int combo}) {
    switch (clearedLines) {
      case 1:
        return 100 + combo * 25;
      case 2:
        return 300 + combo * 50;
      case 3:
        return 500 + combo * 75;
      case 4:
        return 800 + combo * 100;
      default:
        return clearedLines * 200 + combo * 50;
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
    _stats = GameStats(
      bestScore: _stats.bestScore,
      bestScorePersisted: _stats.bestScorePersisted,
    );
    _board = GameBoard.fromConfig(_config);
    _activePiece = null;
    _nextPieces
      ..clear()
      ..addAll(_generatePieces(3));
    _clearLineFlash();
    _landingFlashActive = false;
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

  Future<void> _updateBestScore() async {
    if (_preferences == null) return;
    final currentBest = _preferences!.getInt(_bestScoreKey) ?? 0;
    if (_stats.score > currentBest) {
      await _preferences!.setInt(_bestScoreKey, _stats.score);
      _stats = _stats.copyWith(
        bestScore: _stats.score,
        bestScorePersisted: true,
      );
    }
  }

  static const _bestScoreKey = 'best_score';
  static const _soundKey = 'sound_enabled';
  static const _hapticsKey = 'haptics_enabled';

  void _triggerLineClearFlash(Set<int> indexes) {
    _lineClearFlashToken++;
    final token = _lineClearFlashToken;
    _clearedRows = indexes.isEmpty ? const {} : Set<int>.from(indexes);
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 320), () {
      if (_lineClearFlashToken == token) {
        _clearLineFlash();
        notifyListeners();
      }
    });
  }

  void _clearLineFlash() {
    _clearedRows = const {};
  }

  void _triggerLandingFlash() {
    _landingFlashToken++;
    final token = _landingFlashToken;
    _landingFlashActive = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (_landingFlashToken == token) {
        _landingFlashActive = false;
        notifyListeners();
      }
    });
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    _preferences?.setBool(_soundKey, _soundEnabled);
    notifyListeners();
  }

  void toggleHaptics() {
    _hapticsEnabled = !_hapticsEnabled;
    _preferences?.setBool(_hapticsKey, _hapticsEnabled);
    notifyListeners();
  }
}
