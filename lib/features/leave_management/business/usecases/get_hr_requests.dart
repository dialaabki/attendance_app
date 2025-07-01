import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/leave_management/business/entities/leave_request_entity.dart';
import 'package:attendance_app/features/leave_management/business/repositories/leave_management_repository.dart';
import 'package:dartz/dartz.dart';

class GetHrRequests {
  final LeaveManagementRepository repository;
  GetHrRequests(this.repository);
  
  // Use .watch() convention for streams
  Stream<Either<Failure, List<LeaveRequestEntity>>> watch(NoParams params) {
    return repository.getRequestsForHr();
  }
}