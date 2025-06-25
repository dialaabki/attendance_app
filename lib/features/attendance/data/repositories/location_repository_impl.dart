import 'package:attendance_app/core/errors/exceptions.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/features/attendance/business/repositories/location_repository.dart';
import 'package:attendance_app/features/attendance/data/datasources/location_local_data_source.dart';
import 'package:dartz/dartz.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationLocalDataSource dataSource;
  LocationRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, bool>> isWithinGeofence(double targetLatitude, double targetLongitude) async {
    try {
      final result = await dataSource.isWithinGeofence(targetLatitude, targetLongitude);
      return Right(result);
    } on LocationException catch(e) {
      return Left(LocationFailure(e.message));
    }
  }
}