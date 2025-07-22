// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/wifi_provider.dart';
// import '../models/wifi_network.dart';
// import 'network_tile.dart';

// class NetworkList extends StatelessWidget {
//   const NetworkList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<WiFiProvider>(
//       builder: (context, provider, child) {
//         if (provider.availableNetworks.isEmpty) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.wifi_off,
//                   size: 64,
//                   color: Colors.grey,
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   'No networks found',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Try scanning again or move to a different location',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           );
//         }

//         return Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: provider.availableNetworks.length,
//                 itemBuilder: (context, index) {
//                   final network = provider.availableNetworks[index];
//                   return NetworkTile(
//                     network: network,
//                     onTap: () => provider.connectToNetwork(network),
//                     showDistance: !provider.canScanWiFi,
//                     userLocation: provider.currentLocation,
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }