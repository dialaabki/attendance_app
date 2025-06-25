import 'package:attendance_app/features/attendance/business/entities/daily_stats_entity.dart';

class DailyStatsModel extends DailyStatsEntity {
  const DailyStatsModel({
    required super.lockedIn,
    required super.lockedOut,
    required super.late,
  });
}