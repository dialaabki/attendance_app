import 'dart:async'; 
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/features/leave_management/business/entities/leave_request_entity.dart';
import 'package:attendance_app/features/leave_management/business/repositories/leave_management_repository.dart';
import 'package:dartz/dartz.dart';

class GetMyRequests {
  final LeaveManagementRepository repository;
  GetMyRequests(this.repository);

  Stream<Either<Failure, List<LeaveRequestEntity>>> watch(String userId) {
  
    final controller = StreamController<Either<Failure, List<LeaveRequestEntity>>>.broadcast(sync: true);

    final subscription = repository.getMyRequests(userId).listen(
      (data) {
        if (!controller.isClosed) {
          controller.add(data);
        }
      },
      onError: (error) {
        if (!controller.isClosed) {
          controller.add(Left(ServerFailure(error.toString())));
        }
      },
      onDone: () {
        controller.close();
      }
    );

    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }
}