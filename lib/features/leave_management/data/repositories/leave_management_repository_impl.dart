import 'package:attendance_app/core/errors/exceptions.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/features/leave_management/business/entities/leave_request_entity.dart';
import 'package:attendance_app/features/leave_management/business/repositories/leave_management_repository.dart';
import 'package:attendance_app/features/leave_management/business/usecases/submit_request.dart';
import 'package:attendance_app/features/leave_management/data/datasources/leave_management_remote_data_source.dart';
import 'package:dartz/dartz.dart';

class LeaveManagementRepositoryImpl implements LeaveManagementRepository {
  final LeaveManagementRemoteDataSource remoteDataSource;
  LeaveManagementRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<LeaveRequestEntity>>> getMyRequests(String userId) {
    try {
      return remoteDataSource.getMyRequests(userId).map((requests) => Right(requests));
    } on ServerException catch(e) {
      return Stream.value(Left(ServerFailure(e.message)));
    }
  }

  @override
  Stream<Either<Failure, List<LeaveRequestEntity>>> getRequestsForHr() {
    try {
      return remoteDataSource.getRequestsForHr().map((requests) => Right(requests));
    } on ServerException catch(e) {
      return Stream.value(Left(ServerFailure(e.message)));
    }
  }

  @override
  Future<Either<Failure, void>> submitRequest(SubmitRequestParams params) async {
    try {
      await remoteDataSource.submitRequest(params);
      return const Right(null);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateRequestStatus(String requestId, String newStatus) async {
     try {
      await remoteDataSource.updateRequestStatus(requestId, newStatus);
      return const Right(null);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    }
  }
}