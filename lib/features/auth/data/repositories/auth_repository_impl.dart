import 'package:attendance_app/core/errors/exceptions.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/auth/business/repositories/auth_repository.dart';
import 'package:attendance_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
     try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}