import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/features/leave_management/business/entities/leave_request_entity.dart';
import 'package:attendance_app/features/leave_management/business/usecases/submit_request.dart';
import 'package:dartz/dartz.dart';

abstract class LeaveManagementRepository {
  Stream<Either<Failure, List<LeaveRequestEntity>>> getRequestsForHr();
  Stream<Either<Failure, List<LeaveRequestEntity>>> getMyRequests(String userId);
  Future<Either<Failure, void>> submitRequest(SubmitRequestParams params);
  Future<Either<Failure, void>> updateRequestStatus(String requestId, String newStatus);
}