import 'package:flutter/material.dart';
import '../models/wifi_network.dart';

class WiFiNetworkTile extends StatelessWidget {
  final String ssid;
  final int? signalLevel;
  final VoidCallback onTap;

  const WiFiNetworkTile({
    super.key,
    required this.ssid,
    this.signalLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(
          Icons.wifi,
          color: _getSignalColor(),
        ),
        title: Text(
          ssid,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(_getSignalStrengthText()),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Color _getSignalColor() {
    if (signalLevel == null) return Colors.grey;
    if (signalLevel! > -50) return Colors.green;
    if (signalLevel! > -70) return Colors.orange;
    return Colors.red;
  }

  String _getSignalStrengthText() {
    if (signalLevel == null) return 'Signal strength unknown';
    if (signalLevel! > -50) return 'Excellent signal';
    if (signalLevel! > -70) return 'Good signal';
    return 'Weak signal';
  }
}