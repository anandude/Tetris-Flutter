import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../board/widgets/board_view.dart';
import '../controllers/game_controller.dart';
import '../models/game_state.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameController.scope(
      child: const _GameScaffold(),
    );
  }
}

class _GameScaffold extends StatelessWidget {
  const _GameScaffold();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tetris'),
        actions: [
          IconButton(
            icon: Icon(
              controller.phase == GamePhase.running
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
            onPressed: () {
              switch (controller.phase) {
                case GamePhase.running:
                  controller.pause();
                  break;
                case GamePhase.paused:
                  controller.resume();
                  break;
                default:
                  controller.restart();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.restart,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: BoardView(
                  board: controller.board,
                  activePiece: controller.activePiece,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _StatsBar(controller: controller),
            const SizedBox(height: 16),
            _Controls(controller: controller),
            if (controller.phase == GamePhase.gameOver)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FilledButton(
                  onPressed: controller.restart,
                  child: const Text('Play Again'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatTile(label: 'Score', value: controller.stats.score.toString()),
        _StatTile(label: 'Level', value: controller.stats.level.toString()),
        _StatTile(label: 'Lines', value: controller.stats.linesCleared.toString()),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final phase = controller.phase;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.rotate_right),
          onPressed: phase == GamePhase.running ? controller.rotate : null,
        ),
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.arrow_back),
          onPressed: phase == GamePhase.running ? controller.moveLeft : null,
        ),
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.arrow_downward),
          onPressed: phase == GamePhase.running ? controller.softDrop : null,
        ),
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.arrow_forward),
          onPressed: phase == GamePhase.running ? controller.moveRight : null,
        ),
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.file_download),
          onPressed: phase == GamePhase.running ? controller.hardDrop : null,
        ),
      ],
    );
  }
}

