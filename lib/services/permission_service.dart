import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class PermissionService {
  static Future<bool> requestWiFiPermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.location,
        Permission.nearbyWifiDevices,
      ].request();
      return statuses.values.every((status) => status.isGranted);
    } else if (Platform.isIOS) {
      final status = await Permission.locationWhenInUse.request();
      return status.isGranted;
    }
    return false;
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
