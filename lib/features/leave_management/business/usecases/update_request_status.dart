import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/leave_management/business/repositories/leave_management_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UpdateRequestStatus implements UseCase<void, UpdateRequestParams> {
  final LeaveManagementRepository repository;
  UpdateRequestStatus(this.repository);
  
  @override
  Future<Either<Failure, void>> call(UpdateRequestParams params) async {
    return repository.updateRequestStatus(params.requestId, params.newStatus);
  }
}

class UpdateRequestParams extends Equatable {
  final String requestId;
  final String newStatus; // "Approved" or "Declined"

  const UpdateRequestParams({
    required this.requestId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [requestId, newStatus];
}