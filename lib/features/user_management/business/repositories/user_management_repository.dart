import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/user_management/business/usecases/add_employee.dart';
import 'package:dartz/dartz.dart';

abstract class UserManagementRepository {
  Stream<Either<Failure, List<UserEntity>>> getAllEmployees();
  Future<Either<Failure, void>> addEmployee(AddEmployeeParams params);
}