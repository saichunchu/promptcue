// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'dart:io';
// import '../providers/wifi_provider.dart';

// class ConnectionStatus extends StatelessWidget {
//   const ConnectionStatus({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<WiFiProvider>(
//       builder: (context, provider, child) {
//         final network = provider.selectedNetwork;
//         if (network == null) {
//           return const SizedBox.shrink();
//         }

//         return Card(
//           elevation: 8,
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.wifi,
//                     size: 48,
//                     color: Colors.green,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Connection Ready!',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   Platform.isIOS 
//                       ? 'Use these credentials to connect manually'
//                       : 'Successfully connected to network',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 24),
//                 _buildNetworkInfo(context, network),
//                 if (Platform.isIOS) ...[
//                   const SizedBox(height: 16),
//                   _buildIOSInstructions(),
//                 ],
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildNetworkInfo(BuildContext context, network) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Network Name (SSID):',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.copy, size: 18),
//                 onPressed: () => _copyToClipboard(context, network.ssid, 'SSID'),
//               ),
//             ],
//           ),
//           Text(
//             network.ssid,
//             style: const TextStyle(
//               fontSize: 16,
//               fontFamily: 'monospace',
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Password:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.copy, size: 18),
//                 onPressed: () => _copyToClipboard(context, network.decryptedPassword, 'Password'),
//               ),
//             ],
//           ),
//           Text(
//             network.decryptedPassword,
//             style: const TextStyle(
//               fontSize: 16,
//               fontFamily: 'monospace',
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildIOSInstructions() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.info, color: Colors.blue[700], size: 20),
//               const SizedBox(width: 8),
//               Text(
//                 'How to connect on iOS:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue[700],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             '1. Go to Settings → Wi-Fi\n'
//             '2. Find and tap the network name\n'
//             '3. Enter the password shown above\n'
//             '4. Tap "Join"',
//             style: TextStyle(fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }

//   void _copyToClipboard(BuildContext context, String text, String label) {
//     Clipboard.setData(ClipboardData(text: text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$label copied to clipboard'),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }