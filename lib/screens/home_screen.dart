import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../models/wifi_network.dart';
import '../services/wifi_database_service.dart';
import '../services/permission_service.dart';
import '../services/wifi_scanner_service.dart';
import '../widgets/wifi_network_tile.dart';

enum ScanState { idle, loading, scanning, connecting }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  ScanState _currentState = ScanState.idle;
  String _statusMessage = 'Ready to discover WiFi networks around you';
  List<String> _availableNetworks = [];
  
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      await WiFiDatabaseService.instance.loadDatabase();
      setState(() {
        _statusMessage = 'Ready to discover WiFi networks around you';
      });
      _slideController.forward();
    } catch (e) {
      _showErrorDialog('Initialization Error', 'Failed to load WiFi database: $e');
    }
  }

  Future<void> _onScanAndConnect() async {
    setState(() {
      _currentState = ScanState.loading;
      _statusMessage = 'Requesting permissions...';
      _availableNetworks.clear();
    });

    try {
      // Request permissions
      final permissionsGranted = await PermissionService.requestWiFiPermissions();
      if (!permissionsGranted) {
        throw Exception('Required permissions not granted');
      }

      // Check location services
      if (!await PermissionService.isLocationServiceEnabled()) {
        throw Exception('Location services disabled. Enable GPS to scan WiFi.');
      }

      // Perform platform-specific scanning
      if (Platform.isAndroid) {
        await _performAndroidScan();
      } else if (Platform.isIOS) {
        await _performIOSScan();
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      _showErrorDialog('Scan Error', e.toString());
      setState(() {
        _currentState = ScanState.idle;
        _statusMessage = 'Scan failed. Ready to try again';
      });
    }
  }

  Future<void> _performAndroidScan() async {
    setState(() {
      _currentState = ScanState.scanning;
      _statusMessage = 'Scanning for nearby WiFi networks...';
    });

    final scannedNetworks = await WiFiScannerService.scanForNetworks();
    final databaseService = WiFiDatabaseService.instance;
    
    final matchedSSIDs = scannedNetworks
        .where((ap) => databaseService.findNetworkBySSID(ap.ssid) != null)
        .map((ap) => ap.ssid)
        .toSet()
        .toList();

    if (matchedSSIDs.isEmpty) {
      throw Exception('No nearby WiFi networks match our database');
    }

    setState(() {
      _currentState = ScanState.idle;
      _availableNetworks = matchedSSIDs;
      _statusMessage = 'Found ${matchedSSIDs.length} matching networks. Tap to connect!';
    });
  }

  Future<void> _performIOSScan() async {
    setState(() {
      _currentState = ScanState.scanning;
      _statusMessage = 'Finding nearby WiFi networks...';
    });

    final position = await PermissionService.getCurrentPosition();
    final databaseService = WiFiDatabaseService.instance;
    
    final nearbyNetworks = databaseService.findNetworksNearLocation(
      position.latitude,
      position.longitude,
      50.0, // 50 meters radius
    );

    if (nearbyNetworks.isEmpty) {
      throw Exception('No WiFi networks from our database found within 50 meters');
    }

    setState(() {
      _currentState = ScanState.idle;
      _availableNetworks = nearbyNetworks.map((n) => n.ssid).toList();
      _statusMessage = 'Found ${nearbyNetworks.length} nearby networks. Tap to connect!';
    });
  }

  Future<void> _handleNetworkSelection(String ssid) async {
    final network = WiFiDatabaseService.instance.findNetworkBySSID(ssid);
    if (network == null) {
      _showErrorDialog('Error', 'Network not found in database');
      return;
    }

    if (Platform.isAndroid) {
      await _connectToNetworkAndroid(network);
    } else {
      _showManualConnectionInfoIOS(network);
    }
  }

  Future<void> _connectToNetworkAndroid(WifiNetwork network) async {
    setState(() {
      _currentState = ScanState.connecting;
      _statusMessage = 'Connecting to ${network.ssid}...';
    });

    try {
      final success = await WiFiScannerService.connectToNetwork(network);
      if (success) {
        _showSuccessDialog('Connected!', 'Successfully connected to ${network.ssid}');
        setState(() {
          _statusMessage = 'Connected to ${network.ssid} ✨';
        });
      } else {
        throw Exception('Failed to connect to ${network.ssid}');
      }
    } catch (e) {
      _showErrorDialog('Connection Error', e.toString());
      setState(() {
        _statusMessage = 'Connection failed. Ready to try again';
      });
    } finally {
      setState(() {
        _currentState = ScanState.idle;
      });
    }
  }

  void _showManualConnectionInfoIOS(WifiNetwork network) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.wifi,
                  color: Colors.blue.shade600,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Connect to ${network.ssid}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Go to Settings > Wi-Fi and connect manually:",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Network:', network.ssid),
                    const SizedBox(height: 8),
                    _buildInfoRow('Password:', network.decryptedPassword),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: network.decryptedPassword));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Password copied to clipboard!'),
                              ],
                            ),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red.shade600,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade600,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade100,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.wifi,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'WiFi Connect',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Header section with animation
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _currentState == ScanState.idle ? _pulseAnimation.value : 1.0,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade200,
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _currentState == ScanState.connecting ? Icons.sync : Icons.wifi,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'WiFi Connect',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildActionButton(),
                    ],
                  ),
                ),
              ),
              
              // Networks list with better styling
              if (_availableNetworks.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.router,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Available Networks',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_availableNetworks.length}',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _availableNetworks.length,
                      itemBuilder: (context, index) {
                        final ssid = _availableNetworks[index];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 100 + (index * 50)),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: WiFiNetworkTile(
                            ssid: ssid,
                            onTap: () => _handleNetworkSelection(ssid),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    switch (_currentState) {
      case ScanState.loading:
      case ScanState.scanning:
      case ScanState.connecting:
        return Column(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please wait...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      case ScanState.idle:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade500, Colors.blue.shade600],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade200,
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.radar, size: 24),
            label: Text(
              _availableNetworks.isEmpty ? 'Start Scanning' : 'Scan Again',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onPressed: _onScanAndConnect,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
    }
  }
}