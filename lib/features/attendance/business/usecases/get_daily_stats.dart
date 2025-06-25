import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/attendance/business/entities/daily_stats_entity.dart';
import 'package:attendance_app/features/attendance/business/repositories/attendance_repository.dart';
import 'package:dartz/dartz.dart';

class GetDailyStats implements UseCase<DailyStatsEntity, DateTime> {
  final AttendanceRepository repository;
  GetDailyStats(this.repository);

  @override
  Future<Either<Failure, DailyStatsEntity>> call(DateTime date) async {
    return await repository.getDailyStats(date);
  }
}