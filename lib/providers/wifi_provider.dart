// import 'package:flutter/foundation.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:io';

// import '../models/wifi_network.dart';
// import '../services/wifi_service.dart';
// import '../services/location_service.dart';
// import '../services/permission_service.dart';
// import '../data/wifi_database.dart';

// enum WiFiAppState {
//   initial,
//   requestingPermissions,
//   permissionDenied,
//   scanning,
//   showingNetworks,
//   connecting,
//   connected,
//   error,
// }

// class WiFiProvider with ChangeNotifier {
//   WiFiAppState _state = WiFiAppState.initial;
//   List<WiFiNetwork> _availableNetworks = [];
//   WiFiNetwork? _selectedNetwork;
//   String _errorMessage = '';
//   bool _isFirstTime = true;
//   Position? _currentLocation;
//   bool _canScanWiFi = false;

//   // Getters
//   WiFiAppState get state => _state;
//   List<WiFiNetwork> get availableNetworks => _availableNetworks;
//   WiFiNetwork? get selectedNetwork => _selectedNetwork;
//   String get errorMessage => _errorMessage;
//   bool get isFirstTime => _isFirstTime;
//   Position? get currentLocation => _currentLocation;
//   bool get canScanWiFi => _canScanWiFi;

//   Future<void> initialize() async {
//     _canScanWiFi = await WiFiService.canScanWiFi();
//     _isFirstTime = !(await PermissionService.checkWiFiPermissions());
//     notifyListeners();
//   }

//   Future<void> scanAndConnect() async {
//     if (_isFirstTime) {
//       await requestPermissions();
//     } else {
//       await scanNetworks();
//     }
//   }

//   Future<void> requestPermissions() async {
//     _setState(WiFiAppState.requestingPermissions);
    
//     try {
//       final granted = await PermissionService.requestWiFiPermissions();
      
//       if (granted) {
//         _isFirstTime = false;
//         await scanNetworks();
//       } else {
//         _setState(WiFiAppState.permissionDenied, 
//           'Permissions required to scan WiFi networks');
//       }
//     } catch (e) {
//       _setState(WiFiAppState.error, 'Error requesting permissions: $e');
//     }
//   }

//   Future<void> scanNetworks() async {
//     _setState(WiFiAppState.scanning);
    
//     try {
//       if (_canScanWiFi) {
//         await _scanWiFiNetworks();
//       } else {
//         await _scanUsingLocation();
//       }
//     } catch (e) {
//       _setState(WiFiAppState.error, 'Error scanning networks: $e');
//     }
//   }

//   Future<void> _scanWiFiNetworks() async {
//     try {
//       final scannedNetworks = await WiFiService.scanAvailableNetworks();
//       final matchingNetworks = await WiFiService.getMatchingNetworks(scannedNetworks);
      
//       _availableNetworks = matchingNetworks;
      
//       if (_availableNetworks.isEmpty) {
//         _setState(WiFiAppState.error, 
//           'No matching networks found in database');
//       } else {
//         _setState(WiFiAppState.showingNetworks);
//       }
//     } catch (e) {
//       _setState(WiFiAppState.error, 'Error scanning WiFi: $e');
//     }
//   }

//   Future<void> _scanUsingLocation() async {
//     try {
//       final position = await LocationService.getCurrentLocation();
      
//       if (position == null) {
//         _setState(WiFiAppState.error, 
//           'Unable to get current location');
//         return;
//       }

//       _currentLocation = position;
      
//       final nearbyNetworks = WiFiDatabase.getNearbyNetworks(
//         position.latitude,
//         position.longitude,
//       );
      
//       _availableNetworks = nearbyNetworks;
      
//       if (_availableNetworks.isEmpty) {
//         _setState(WiFiAppState.error, 
//           'No nearby networks found within 50 meters');
//       } else {
//         _setState(WiFiAppState.showingNetworks);
//       }
//     } catch (e) {
//       _setState(WiFiAppState.error, 'Error getting location: $e');
//     }
//   }

//   Future<void> connectToNetwork(WiFiNetwork network) async {
//     _selectedNetwork = network;
//     _setState(WiFiAppState.connecting);
    
//     try {
//       if (Platform.isIOS) {
//         // On iOS, we can't programmatically connect
//         // Just show success state with manual connection info
//         _setState(WiFiAppState.connected);
//         return;
//       }

//       final connected = await WiFiService.connectToNetwork(
//         network.ssid,
//         network.decryptedPassword,
//       );
      
//       if (connected) {
//         _setState(WiFiAppState.connected);
//       } else {
//         _setState(WiFiAppState.error, 'Failed to connect to network');
//       }
//     } catch (e) {
//       _setState(WiFiAppState.error, 'Error connecting to network: $e');
//     }
//   }

//   Future<void> openAppSettings() async {
//     try {
//       await PermissionService.openAppSettings();
//     } catch (e) {
//       _setState(WiFiAppState.error, 'Error opening settings: $e');
//     }
//   }

//   void resetToInitial() {
//     _setState(WiFiAppState.initial);
//     _availableNetworks.clear();
//     _selectedNetwork = null;
//     _currentLocation = null;
//   }

//   void _setState(WiFiAppState newState, [String? errorMessage]) {
//     _state = newState;
//     if (errorMessage != null) {
//       _errorMessage = errorMessage;
//     } else {
//       _errorMessage = '';
//     }
//     notifyListeners();
//   }
// }