import 'dart:developer' as developer;

void logInfo(String message) {
  developer.log(message, name: 'Tetris');
}

void logError(String message, [Object? error, StackTrace? stackTrace]) {
  developer.log(
    message,
    name: 'Tetris',
    error: error,
    stackTrace: stackTrace,
  );
}

