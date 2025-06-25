import 'package:equatable/equatable.dart';

class DailyStatsEntity extends Equatable {
  final int lockedIn;
  final int lockedOut;
  final int late;

  const DailyStatsEntity({
    required this.lockedIn,
    required this.lockedOut,
    required this.late,
  });

  @override
  List<Object?> get props => [lockedIn, lockedOut, late];
}