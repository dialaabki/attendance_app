import 'package:attendance_app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class LocationRepository {
  Future<Either<Failure, bool>> isWithinGeofence(double targetLatitude, double targetLongitude);
}