import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/attendance/business/entities/attendance_record_entity.dart';
import 'package:attendance_app/features/attendance/business/entities/daily_stats_entity.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_filtered_employees.dart';
import 'package:dartz/dartz.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, void>> clockIn(String userId);
  Future<Either<Failure, void>> clockOut(String userId);
  Future<Either<Failure, void>> startBreak(String userId);
  Future<Either<Failure, void>> endBreak(String userId);
  
  Future<Either<Failure, AttendanceRecordEntity?>> getTodayAttendance(String userId);
  Future<Either<Failure, AttendanceRecordEntity?>> getEmployeeTimesheetForDate(String userId, DateTime date);
  Future<Either<Failure, DailyStatsEntity>> getDailyStats(DateTime date);
  Future<Either<Failure, List<UserEntity>>> getFilteredEmployees(EmployeeFilterParams params);
}