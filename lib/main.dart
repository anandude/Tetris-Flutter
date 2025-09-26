import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/game_config.dart';
import 'features/game/widgets/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<GameConfig>(
          create: (_) => const GameConfig(),
        ),
      ],
      child: MaterialApp(
        title: 'Tetris',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const GameScreen(),
      ),
    );
  }
}
