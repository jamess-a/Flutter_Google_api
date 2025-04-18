import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'Location services are disabled.';

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw 'Location permissions are denied';
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}
