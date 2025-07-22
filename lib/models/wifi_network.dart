
import 'dart:convert';


class WifiNetwork {
  final String ssid;
  final String passwordEncrypted;
  final double latitude;
  final double longitude;

  WifiNetwork({
    required this.ssid,
    required this.passwordEncrypted,
    required this.latitude,
    required this.longitude,
  });

  factory WifiNetwork.fromJson(Map<String, dynamic> json) {
    return WifiNetwork(
      ssid: json['ssid'],
      passwordEncrypted: json['password_encrypted'],
      latitude: json['location']['latitude'],
      longitude: json['location']['longitude'],
    );
  }

  String get decryptedPassword {
    try {
      return utf8.decode(base64.decode(passwordEncrypted));
    } catch (e) {
      // Handle potential decoding errors gracefully
      return "Error decoding password";
    }
  }
}