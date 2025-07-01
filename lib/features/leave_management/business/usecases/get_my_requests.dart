import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/features/leave_management/business/entities/leave_request_entity.dart';
import 'package:attendance_app/features/leave_management/business/repositories/leave_management_repository.dart';
import 'package:dartz/dartz.dart';

class GetMyRequests {
  final LeaveManagementRepository repository;
  GetMyRequests(this.repository);
  
  // Use .watch() convention for streams
  Stream<Either<Failure, List<LeaveRequestEntity>>> watch(String userId) {
    return repository.getMyRequests(userId);
  }
}