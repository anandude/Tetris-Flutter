import 'package:equatable/equatable.dart';

class BoardPosition extends Equatable {
  const BoardPosition(this.row, this.column);

  final int row;
  final int column;

  @override
  List<Object> get props => [row, column];
}

