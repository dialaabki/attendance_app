import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/attendance/business/repositories/attendance_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

enum EmployeeFilter { lockedIn, lockedOut, late }

class GetFilteredEmployees implements UseCase<List<UserEntity>, EmployeeFilterParams> {
  final AttendanceRepository repository;
  GetFilteredEmployees(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(EmployeeFilterParams params) async {
    return await repository.getFilteredEmployees(params);
  }
}

class EmployeeFilterParams extends Equatable {
  final EmployeeFilter filter;
  final DateTime date;

  const EmployeeFilterParams({required this.filter, required this.date});

  @override
  List<Object?> get props => [filter, date];
}