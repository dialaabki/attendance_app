import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/leave_management/business/repositories/leave_management_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SubmitRequest implements UseCase<void, SubmitRequestParams> {
  final LeaveManagementRepository repository;
  SubmitRequest(this.repository);
  
  @override
  Future<Either<Failure, void>> call(SubmitRequestParams params) async {
    return repository.submitRequest(params);
  }
}

class SubmitRequestParams extends Equatable {
  final String userId;
  final String userName;
  final String requestType;
  final DateTime date;
  final String reason;

  const SubmitRequestParams({
    required this.userId,
    required this.userName,
    required this.requestType,
    required this.date,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, requestType, date, reason];
}