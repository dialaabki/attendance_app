import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/auth/business/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetCurrentUser implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;
  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}