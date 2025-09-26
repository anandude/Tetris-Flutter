import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../../board/widgets/board_view.dart';
import '../controllers/game_controller.dart';
import '../models/game_state.dart';
import '../../board/models/tetromino_instance.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameController.scope(child: const _GameScaffold());
  }
}

class _GameScaffold extends StatelessWidget {
  const _GameScaffold();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final landingFlash = controller.landingFlashActive;
    final theme = Theme.of(context);
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
                  _showPauseSheet(context, controller);
                  break;
                case GamePhase.paused:
                  controller.resume();
                  Navigator.of(context, rootNavigator: true).maybePop();
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
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        color: landingFlash
            ? theme.colorScheme.surfaceBright
            : theme.colorScheme.surface,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset = MediaQuery.of(context).viewPadding.bottom;
              final footerHeight = math.min(
                constraints.maxHeight * 0.45,
                260.0,
              );
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: _ResponsivePlayfield(controller: controller),
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: footerHeight + bottomInset / 2,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Material(
                              color: theme.colorScheme.surfaceContainerLowest
                                  .withValues(alpha: 0.9),
                              child: SingleChildScrollView(
                                padding: EdgeInsets.fromLTRB(
                                  12,
                                  16,
                                  12,
                                  16 + bottomInset,
                                ),
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _StatsBar(controller: controller),
                                    const SizedBox(height: 16),
                                    _Controls(controller: controller),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (controller.phase == GamePhase.gameOver)
                    Positioned.fill(
                      child: Container(
                        color: theme.colorScheme.surfaceTint.withValues(
                          alpha: 0.08,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(24),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.96,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.shadow.withValues(
                                  alpha: 0.18,
                                ),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 28,
                              horizontal: 24,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Game Over',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Score: ${controller.stats.score}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 24),
                                FilledButton(
                                  onPressed: controller.restart,
                                  child: const Text('Play Again'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPauseSheet(BuildContext context, GameController controller) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => _PauseSheet(controller: controller),
    );
  }
}

class _ResponsivePlayfield extends StatelessWidget {
  const _ResponsivePlayfield({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: BoardView(
              board: controller.board,
              activePiece: controller.activePiece,
              highlightClearedLines: controller.highlightRows,
            ),
          ),
        ),
        if (controller.nextQueue.isNotEmpty) ...[
          const SizedBox(height: 12),
          _NextQueuePreview(queue: controller.nextQueue),
        ],
      ],
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatTile(label: 'Score', value: controller.stats.score.toString()),
        _StatTile(label: 'Best', value: controller.stats.bestScore.toString()),
        _StatTile(label: 'Combo x', value: controller.stats.combo.toString()),
        _StatTile(label: 'Level', value: controller.stats.level.toString()),
        _StatTile(
          label: 'Lines',
          value: controller.stats.linesCleared.toString(),
        ),
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
    final theme = Theme.of(context);
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.85,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final phase = controller.phase;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _ControlButton(
          icon: Icons.rotate_right,
          tooltip: 'Rotate',
          onPressed: phase == GamePhase.running ? controller.rotate : null,
        ),
        _ControlButton(
          icon: Icons.arrow_back,
          tooltip: 'Move Left',
          onPressed: phase == GamePhase.running ? controller.moveLeft : null,
        ),
        _ControlButton(
          icon: Icons.arrow_downward,
          tooltip: 'Soft Drop',
          onPressed: phase == GamePhase.running ? controller.softDrop : null,
        ),
        _ControlButton(
          icon: Icons.arrow_forward,
          tooltip: 'Move Right',
          onPressed: phase == GamePhase.running ? controller.moveRight : null,
        ),
        _ControlButton(
          icon: Icons.file_download,
          tooltip: 'Hard Drop',
          onPressed: phase == GamePhase.running ? controller.hardDrop : null,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 64,
        height: 56,
        child: FilledButton.tonal(
          onPressed: onPressed,
          child: Icon(icon, size: 24),
        ),
      ),
    );
  }
}

class _NextQueuePreview extends StatelessWidget {
  const _NextQueuePreview({required this.queue});

  final List<TetrominoInstance> queue;

  @override
  Widget build(BuildContext context) {
    if (queue.isEmpty) return const SizedBox.shrink();
    final preview = queue.take(3).toList();
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: preview
            .map(
              (piece) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _MiniPiecePreview(piece: piece),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MiniPiecePreview extends StatelessWidget {
  const _MiniPiecePreview({required this.piece});

  final TetrominoInstance piece;

  @override
  Widget build(BuildContext context) {
    final matrix = piece.shape.rotationAt(0);
    return AspectRatio(
      aspectRatio: matrix[0].length / matrix.length,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final row in matrix)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final cell in row)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: cell == 0
                                ? Colors.transparent
                                : piece.shape.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PauseSheet extends StatelessWidget {
  const _PauseSheet({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Paused',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.resume();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingSwitch(
            label: 'Sound Effects',
            value: controller.soundEnabled,
            onChanged: (_) => controller.toggleSound(),
          ),
          _SettingSwitch(
            label: 'Haptics',
            value: controller.hapticsEnabled,
            onChanged: (value) async {
              controller.toggleHaptics();
              final hasVibrator = await Vibration.hasVibrator();
              if (value && hasVibrator == true) {
                Vibration.vibrate(duration: 40);
              }
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Restart'),
            onPressed: () {
              Navigator.of(context).pop();
              controller.restart();
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.resume();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}
