// import 'dart:io';
// import 'package:wifi_scan/wifi_scan.dart';
// import 'package:wifi_iot/wifi_iot.dart';
// import '../models/wifi_network.dart';
// import '../data/wifi_database.dart';

// class WiFiService {
//   static Future<bool> canScanWiFi() async {
//     if (Platform.isIOS) {
//       // WiFi scanning is not available on iOS due to Apple restrictions
//       return false;
//     }
    
//     try {
//       final can = await WiFiScan.instance.canGetScannedResults();
//       return can == CanGetScannedResults.yes;
//     } catch (e) {
//       return false;
//     }
//   }

//   static Future<List<ScannedWiFi>> scanAvailableNetworks() async {
//     try {
//       if (!await canScanWiFi()) {
//         throw Exception('WiFi scanning not supported on this device');
//       }

//       // Start scanning
//       await WiFiScan.instance.startScan();
      
//       // Wait a bit for scan to complete
//       await Future.delayed(const Duration(seconds: 3));

//       // Get scan results
//       final results = await WiFiScan.instance.getScannedResults();
      
//       return results.map((result) => ScannedWiFi(
//         ssid: result.ssid,
//         bssid: result.bssid,
//         level: result.level,
//         frequency: result.frequency,
//       )).where((wifi) => wifi.ssid.isNotEmpty).toList();
//     } catch (e) {
//       print('Error scanning WiFi: $e');
//       return [];
//     }
//   }

//   static Future<List<WiFiNetwork>> getMatchingNetworks(List<ScannedWiFi> scannedNetworks) async {
//     final ssids = scannedNetworks.map((network) => network.ssid).toList();
//     return WiFiDatabase.getNetworksBySSIDs(ssids);
//   }

//   static Future<bool> connectToNetwork(String ssid, String password) async {
//     try {
//       if (Platform.isAndroid) {
//         return await _connectToNetworkAndroid(ssid, password);
//       } else if (Platform.isIOS) {
//         // On iOS, we can't programmatically connect to WiFi
//         // We can only provide the credentials to the user
//         return await _connectToNetworkIOS(ssid, password);
//       }
//       return false;
//     } catch (e) {
//       print('Error connecting to WiFi: $e');
//       return false;
//     }
//   }

//   static Future<bool> _connectToNetworkAndroid(String ssid, String password) async {
//     try {
//       final result = await WiFiForIoTPlugin.connect(
//         ssid,
//         password: password,
//         security: NetworkSecurity.WPA,
//         joinOnce: true,
//       );
//       return result;
//     } catch (e) {
//       print('Error connecting to WiFi on Android: $e');
//       return false;
//     }
//   }

//   static Future<bool> _connectToNetworkIOS(String ssid, String password) async {
//     // On iOS, we cannot programmatically connect to WiFi networks
//     // This method exists for consistency, but will always return false
//     // The UI should handle this by showing the credentials to the user
//     return false;
//   }

//   static Future<bool> isConnected() async {
//     try {
//       if (Platform.isAndroid) {
//         return await WiFiForIoTPlugin.isConnected();
//       }
//       // On iOS, we can't easily check WiFi connection status
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

//   static Future<String?> getCurrentSSID() async {
//     try {
//       if (Platform.isAndroid) {
//         final ssid = await WiFiForIoTPlugin.getSSID();
//         return ssid?.replaceAll('"', ''); // Remove quotes if present
//       }
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }

//   static Future<void> disconnect() async {
//     try {
//       if (Platform.isAndroid) {
//         await WiFiForIoTPlugin.disconnect();
//       }
//     } catch (e) {
//       print('Error disconnecting: $e');
//     }
//   }
// }