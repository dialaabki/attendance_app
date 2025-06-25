import 'package:attendance_app/core/errors/exceptions.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/attendance/business/entities/attendance_record_entity.dart';
import 'package:attendance_app/features/attendance/business/entities/daily_stats_entity.dart';
import 'package:attendance_app/features/attendance/business/repositories/attendance_repository.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_filtered_employees.dart';
import 'package:attendance_app/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:dartz/dartz.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  AttendanceRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, void>> clockIn(String userId) async {
    try {
      await remoteDataSource.clockIn(userId);
      return const Right(null);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> clockOut(String userId) async {
    try {
      await remoteDataSource.clockOut(userId);
      return const Right(null);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> startBreak(String userId) async {
    try {
      await remoteDataSource.startBreak(userId);
      return const Right(null);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> endBreak(String userId) async {
    try {
      await remoteDataSource.endBreak(userId);
      return const Right(null);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DailyStatsEntity>> getDailyStats(DateTime date) async {
    try {
      final stats = await remoteDataSource.getDailyStats(date);
      return Right(stats);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AttendanceRecordEntity?>> getEmployeeTimesheetForDate(String userId, DateTime date) async {
    try {
      final record = await remoteDataSource.getEmployeeTimesheetForDate(userId, date);
      return Right(record);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getFilteredEmployees(EmployeeFilterParams params) async {
    try {
      final users = await remoteDataSource.getFilteredEmployees(params);
      return Right(users);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AttendanceRecordEntity?>> getTodayAttendance(String userId) async {
    try {
      final record = await remoteDataSource.getTodayAttendance(userId);
      return Right(record);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    }
  }
}