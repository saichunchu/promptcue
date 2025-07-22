import 'dart:convert';

class WifiNetwork {
  final String ssid;
  final String encryptedPassword;
  final double latitude;
  final double longitude;
  final String? bssid;
  final int? signalLevel;

  WifiNetwork({
    required this.ssid,
    required this.encryptedPassword,
    required this.latitude,
    required this.longitude,
    this.bssid,
    this.signalLevel,
  });

  factory WifiNetwork.fromJson(Map<String, dynamic> json) {
    return WifiNetwork(
      ssid: json['ssid'] ?? '',
      encryptedPassword: json['password'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      bssid: json['bssid'],
      signalLevel: json['signalLevel'],
    );
  }

  String get decryptedPassword {
    try {
      return utf8.decode(base64.decode(encryptedPassword));
    } catch (e) {
      return encryptedPassword; // Fallback if not Base64 encoded
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'password': encryptedPassword,
      'latitude': latitude,
      'longitude': longitude,
      'bssid': bssid,
      'signalLevel': signalLevel,
    };
  }
}