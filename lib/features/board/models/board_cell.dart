import 'dart:ui';

import 'package:equatable/equatable.dart';

class BoardCell extends Equatable {
  const BoardCell({this.color});

  final Color? color;

  bool get isEmpty => color == null;

  @override
  List<Object?> get props => [color];
}

