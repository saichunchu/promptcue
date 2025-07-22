import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WifiNetwork> _dbNetworks = [];
  bool _isLoading = false;
  String _statusMessage =
      'Click the button to scan for WiFi networks.';

  @override
  void initState() {
    super.initState();
    _loadWifiDatabase();
  }

  // --- 1. Load WiFi Database from JSON ---
  Future<void> _loadWifiDatabase() async {
    final String response =
        await rootBundle.loadString('assets/wifi_database.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _dbNetworks = data.map((json) => WifiNetwork.fromJson(json)).toList();
    });
  }

  // --- 2. Main Button Handler ---
  Future<void> _onScanAndConnect() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting permissions...';
    });

    // Request necessary permissions
    bool permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      setState(() {
        _isLoading = false;
        _statusMessage =
            'Permissions denied. Cannot proceed without permissions.';
      });
      _showErrorDialog('Permission Denied',
          'Location and nearby device permissions are required to scan for WiFi networks.');
      return;
    }

    // Platform-specific logic
    if (Platform.isAndroid) {
      await _scanWifiAndroid();
    } else if (Platform.isIOS) {
      await _findNearbyWifiIOS();
    } else {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Unsupported Platform';
      });
      _showErrorDialog('Unsupported Platform',
          'This app currently supports Android and iOS only.');
    }
  }

  // --- 3. Permission Handling ---
  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses;

    if (Platform.isAndroid) {
        // Android requires location and nearby wifi devices permissions
        statuses = await [
            Permission.location,
            Permission.nearbyWifiDevices,
        ].request();
    } else {
        // iOS requires location when in use
        statuses = await [
            Permission.locationWhenInUse,
        ].request();
    }


    return statuses.values.every((status) => status.isGranted);
  }

  // --- 4. Android: Scan for WiFi Networks ---
  Future<void> _scanWifiAndroid() async {
    setState(() {
      _statusMessage = 'Scanning for WiFi networks...';
    });

    final canScan = await WiFiScan.instance.canStartScan(askPermissions: false);
    if (canScan != CanStartScan.yes) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Cannot scan for WiFi. Please ensure permissions are granted and WiFi is enabled.';
      });
      _showErrorDialog('Scanning Error', 'Failed to start WiFi scan. Error code: $canScan');
      return;
    }

    final result = await WiFiScan.instance.startScan();
    if (result) {
      final subscription = WiFiScan.instance.onScannedResults.listen((scannedNetworks) {
        final List<WiFiAccessPoint> filteredAPs = scannedNetworks
            .where((ap) => _dbNetworks.any((dbNet) => dbNet.ssid == ap.ssid))
            .toList();

        if (filteredAPs.isNotEmpty) {
          _showWifiSelectionDialog(filteredAPs.map((ap) => ap.ssid).toList());
        } else {
          _statusMessage = 'No matching WiFi networks found in your area.';
          _showErrorDialog('No Networks Found', 'Scan complete, but no networks from our database were detected.');
        }
        setState(() => _isLoading = false);
      });
      // Ensure we cancel the subscription to avoid memory leaks
      Future.delayed(const Duration(seconds: 15), () => subscription.cancel());

    } else {
       setState(() {
        _isLoading = false;
        _statusMessage = 'Failed to start WiFi scan.';
      });
       _showErrorDialog('Scanning Failed', 'Could not initiate the WiFi scanning process.');
    }
  }

  // --- 5. iOS: Find Nearby WiFi based on GPS ---
  Future<void> _findNearbyWifiIOS() async {
    setState(() {
      _statusMessage = 'Getting your location...';
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _statusMessage = 'Finding nearby networks...';
      });

      List<String> nearbySsids = [];
      for (var network in _dbNetworks) {
        double distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          network.latitude,
          network.longitude,
        );

        if (distanceInMeters <= 50) { // ~50 meters radius
          nearbySsids.add(network.ssid);
        }
      }

      if (nearbySsids.isNotEmpty) {
        _showWifiSelectionDialog(nearbySsids);
      } else {
        _statusMessage = 'No matching WiFi networks found within 50 meters.';
        _showErrorDialog('No Networks Found', 'Could not find any of our registered WiFi networks within a 50-meter radius of your location.');
      }
    } catch (e) {
      _statusMessage = 'Could not get location. Please ensure location services are enabled.';
      _showErrorDialog('Location Error', 'Failed to get your current location. Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- 6. Show WiFi Selection Dialog ---
  void _showWifiSelectionDialog(List<String> ssids) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a WiFi Network'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ssids.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(ssids[index]),
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleWifiSelection(ssids[index]);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // --- 7. Handle Selected WiFi ---
  void _handleWifiSelection(String ssid) {
    final selectedNetwork = _dbNetworks.firstWhere((net) => net.ssid == ssid);
    
    if (Platform.isAndroid) {
      _connectToWifiAndroid(selectedNetwork);
    } else if (Platform.isIOS) {
      _showManualConnectionInfoIOS(selectedNetwork);
    }
  }

  // --- 8. Android: Programmatically Connect ---
  Future<void> _connectToWifiAndroid(WifiNetwork network) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Connecting to ${network.ssid}...';
    });

    try {
      final success = await WifiConnector.connectToWifi(
        ssid: network.ssid,
        password: network.decryptedPassword,
      );
      if (success) {
        _showSuccessDialog('Connection Successful!', 'Successfully connected to ${network.ssid}.');
        setState(() => _statusMessage = 'Connected to ${network.ssid}!');
      } else {
        _showErrorDialog('Connection Failed', 'Could not connect to ${network.ssid}. Please check the password or try again.');
        setState(() => _statusMessage = 'Failed to connect.');
      }
    } catch (e) {
      _showErrorDialog('Connection Error', 'An error occurred while trying to connect: $e');
      setState(() => _statusMessage = 'Connection error.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- 9. iOS: Show Manual Connection Info ---
  void _showManualConnectionInfoIOS(WifiNetwork network) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Connect to ${network.ssid}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('iOS requires you to connect manually.\nGo to Settings > Wi-Fi and use these details:'),
              const SizedBox(height: 16),
              Text('SSID: ${network.ssid}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Password: ${network.decryptedPassword}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Copy Password'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: network.decryptedPassword));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password copied to clipboard!')),
                );
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // --- UI Helper Widgets ---
  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('Great!'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Connect'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.wifi_find, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                'Welcome to WiFi Connect',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.wifi_tethering),
                  label: const Text('Scan & Connect to WiFi'),
                  onPressed: _onScanAndConnect,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
