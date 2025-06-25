import 'package:attendance_app/core/errors/exceptions.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationLocalDataSource {
  Future<bool> isWithinGeofence(double targetLatitude, double targetLongitude);
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final double allowedRadiusInMeters = 100.0;
  
  @override
  Future<bool> isWithinGeofence(double targetLatitude, double targetLongitude) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Location permissions are denied.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw LocationException('Location permissions are permanently denied.');
    } 

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 10));
      double distance = Geolocator.distanceBetween(
        targetLatitude, targetLongitude, position.latitude, position.longitude);
      return distance <= allowedRadiusInMeters;
    } catch (e) {
      throw LocationException('Could not determine your current location. Please check your GPS.');
    }
  }
}