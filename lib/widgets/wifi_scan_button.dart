// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/wifi_provider.dart';

// class WiFiScanButton extends StatelessWidget {
//   const WiFiScanButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<WiFiProvider>(
//       builder: (context, provider, child) {
//         return Container(
//           width: double.infinity,
//           height: 200,
//           child: Card(
//             elevation: 8,
//             child: InkWell(
//               onTap: () => provider.scanAndConnect(),
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       Theme.of(context).primaryColor,
//                       Theme.of(context).primaryColor.withOpacity(0.7),
//                     ],
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.wifi_find,
//                         size: 48,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Scan & Connect to WiFi',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       provider.isFirstTime 
//                           ? 'First time? We\'ll request permissions'
//                           : 'Tap to scan for available networks',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.white70,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }