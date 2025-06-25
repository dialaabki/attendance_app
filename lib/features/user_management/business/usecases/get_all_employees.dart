import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/user_management/business/repositories/user_management_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllEmployees {
  final UserManagementRepository repository;
  GetAllEmployees(this.repository);

  Stream<Either<Failure, List<UserEntity>>> watch(NoParams params) {
    return repository.getAllEmployees();
  }
}