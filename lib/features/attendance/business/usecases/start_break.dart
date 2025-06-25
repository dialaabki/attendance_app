import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/attendance/business/repositories/attendance_repository.dart';
import 'package:dartz/dartz.dart';

class StartBreak implements UseCase<void, String> {
  final AttendanceRepository repository;
  StartBreak(this.repository);

  @override
  Future<Either<Failure, void>> call(String userId) async {
    return await repository.startBreak(userId);
  }
}