import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/attendance/business/repositories/attendance_repository.dart';
import 'package:attendance_app/features/attendance/business/repositories/location_repository.dart';
import 'package:dartz/dartz.dart';

class ClockIn implements UseCase<void, UserEntity> {
  final AttendanceRepository attendanceRepository;
  final LocationRepository locationRepository;

  ClockIn(this.attendanceRepository, this.locationRepository);

  @override
  Future<Either<Failure, void>> call(UserEntity user) async {
    final geofenceCheck = await locationRepository.isWithinGeofence(user.latitude, user.longitude);
    
    return geofenceCheck.fold(
      (failure) => Left(failure),
      (isWithin) {
        if (isWithin) {
          return attendanceRepository.clockIn(user.uid);
        } else {
          return Left(LocationFailure('You are too far from your assigned location: ${user.locationName}.'));
        }
      },
    );
  }
}