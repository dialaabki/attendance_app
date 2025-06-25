import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/attendance/business/entities/attendance_record_entity.dart';
import 'package:attendance_app/features/attendance/business/repositories/attendance_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetEmployeeTimesheet implements UseCase<AttendanceRecordEntity?, TimesheetParams> {
  final AttendanceRepository repository;
  GetEmployeeTimesheet(this.repository);

  @override
  Future<Either<Failure, AttendanceRecordEntity?>> call(TimesheetParams params) async {
    return await repository.getEmployeeTimesheetForDate(params.userId, params.date);
  }
}

class TimesheetParams extends Equatable {
  final String userId;
  final DateTime date;

  const TimesheetParams({required this.userId, required this.date});

  @override
  List<Object?> get props => [userId, date];
}