// services/wifi_scanner_service.dart
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifi_iot/wifi_iot.dart' hide WifiNetwork;
import 'dart:io';
import '../models/wifi_network.dart';

class WiFiScannerService {
  static Future<List<WiFiAccessPoint>> scanForNetworks() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('WiFi scanning only supported on Android');
    }

    final scanStarted = await WiFiScan.instance.startScan();
    if (!scanStarted) {
      throw Exception('Failed to start WiFi scan');
    }

    // Wait for scan to complete
    await Future.delayed(const Duration(seconds: 4));
    return await WiFiScan.instance.getScannedResults();
  }

  static Future<bool> connectToNetwork(WifiNetwork network) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Auto-connect only supported on Android');
    }

    try {
      final result = await WiFiForIoTPlugin.connect(
        network.ssid,
        password: network.decryptedPassword,
        security: NetworkSecurity.WPA,
        joinOnce: true,
        withInternet: true,
      );
      return result;
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }
}