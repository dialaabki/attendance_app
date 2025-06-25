import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LogoutUser implements UseCase<void, NoParams> {
  final AuthRepository repository;
  LogoutUser(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}