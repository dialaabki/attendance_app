import 'package:attendance_app/core/errors/exceptions.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/user_management/business/repositories/user_management_repository.dart';
import 'package:attendance_app/features/user_management/business/usecases/add_employee.dart';
import 'package:attendance_app/features/user_management/data/datasources/user_management_remote_data_source.dart';
import 'package:dartz/dartz.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementRemoteDataSource remoteDataSource;

  UserManagementRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> addEmployee(AddEmployeeParams params) async {
    try {
      await remoteDataSource.addEmployee(params);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<Either<Failure, List<UserEntity>>> getAllEmployees() {
    try {
      return remoteDataSource.getAllEmployees().map((users) => Right(users));
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    } catch (e) {
      return Stream.value(Left(ServerFailure("An unexpected error occurred.")));
    }
  }
}