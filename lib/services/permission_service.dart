import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  static Future<bool> requestWiFiPermissions() async {
    if (Platform.isAndroid) {
      return await _requestAndroidWiFiPermissions();
    } else if (Platform.isIOS) {
      return await _requestIOSPermissions();
    }
    return false;
  }

  static Future<bool> _requestAndroidWiFiPermissions() async {
    final permissions = [
      Permission.location,
      Permission.locationWhenInUse,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    bool allGranted = true;
    for (var status in statuses.values) {
      if (!status.isGranted) {
        allGranted = false;
        break;
      }
    }

    return allGranted;
  }

  static Future<bool> _requestIOSPermissions() async {
    final locationPermission = await Permission.locationWhenInUse.request();
    return locationPermission.isGranted;
  }

  static Future<bool> checkWiFiPermissions() async {
    if (Platform.isAndroid) {
      final locationStatus = await Permission.location.status;
      final locationWhenInUseStatus = await Permission.locationWhenInUse.status;
      return locationStatus.isGranted || locationWhenInUseStatus.isGranted;
    } else if (Platform.isIOS) {
      final locationStatus = await Permission.locationWhenInUse.status;
      return locationStatus.isGranted;
    }
    return false;
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Permission.location.serviceStatus.isEnabled;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  static Future<PermissionStatus> getLocationPermissionStatus() async {
    if (Platform.isAndroid) {
      return await Permission.location.status;
    } else {
      return await Permission.locationWhenInUse.status;
    }
  }

  static String getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted';
      case PermissionStatus.denied:
        return 'Permission denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permission permanently denied. Please enable in settings.';
      case PermissionStatus.restricted:
        return 'Permission restricted';
      default:
        return 'Unknown permission status';
    }
  }
}