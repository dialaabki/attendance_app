import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/attendance/business/entities/attendance_record_entity.dart';
import 'package:attendance_app/features/attendance/business/repositories/attendance_repository.dart';
import 'package:dartz/dartz.dart';

class GetTodayAttendance implements UseCase<AttendanceRecordEntity?, String> {
  final AttendanceRepository repository;
  GetTodayAttendance(this.repository);

  @override
  Future<Either<Failure, AttendanceRecordEntity?>> call(String userId) async {
    return await repository.getTodayAttendance(userId);
  }
}