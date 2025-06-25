import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BreakEntity extends Equatable {
  final Timestamp start;
  final Timestamp? end;

  const BreakEntity({required this.start, this.end});

  @override
  List<Object?> get props => [start, end];
}

class AttendanceRecordEntity extends Equatable {
  final String userId;
  final String date;
  final Timestamp? clockIn;
  final Timestamp? clockOut;
  final String? totalDuration;
  final List<Map<String, dynamic>> breaks;
  final double totalBreakMinutes;

  const AttendanceRecordEntity({
    required this.userId,
    required this.date,
    this.clockIn,
    this.clockOut,
    this.totalDuration,
    required this.breaks,
    required this.totalBreakMinutes,
  });

bool get isOnBreak => breaks.isNotEmpty && breaks.last['end'] == null;
  @override
  List<Object?> get props => [userId, date, clockIn, clockOut, totalDuration, breaks, totalBreakMinutes];
}