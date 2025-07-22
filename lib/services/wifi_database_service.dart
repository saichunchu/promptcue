import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/wifi_network.dart';
import 'dart:math';

class WiFiDatabaseService {
  static WiFiDatabaseService? _instance;
  static WiFiDatabaseService get instance => _instance ??= WiFiDatabaseService._();
  
  WiFiDatabaseService._();

  List<WifiNetwork> _networks = [];
  bool _isLoaded = false;

  List<WifiNetwork> get networks => List.unmodifiable(_networks);
  bool get isLoaded => _isLoaded;

  Future<void> loadDatabase() async {
    if (_isLoaded) return;

    try {
      final response = await rootBundle.loadString('assets/data/Wifi_db.json');
      final data = json.decode(response);
      _networks = (data as List)
          .map((e) => WifiNetwork.fromJson(e as Map<String, dynamic>))
          .toList();
      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load WiFi database: $e');
    }
  }

  WifiNetwork? findNetworkBySSID(String ssid) {
    try {
      return _networks.firstWhere((network) => network.ssid == ssid);
    } catch (e) {
      return null;
    }
  }

  List<WifiNetwork> findNetworksNearLocation(
    double latitude,
    double longitude,
    double radiusInMeters,
  ) {
    return _networks.where((network) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        network.latitude,
        network.longitude,
      );
      return distance <= radiusInMeters;
    }).toList();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Using Haversine formula for distance calculation
    const double earthRadius = 6371000; // meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * (pi / 180);
}