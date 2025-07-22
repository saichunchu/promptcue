// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import '../models/wifi_network.dart';
// import '../services/location_service.dart';

// class NetworkTile extends StatelessWidget {
//   final WiFiNetwork network;
//   final VoidCallback onTap;
//   final bool showDistance;
//   final Position? userLocation;

//   const NetworkTile({
//     super.key,
//     required this.network,
//     required this.onTap,
//     this.showDistance = false,
//     this.userLocation,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(12),
//         leading: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Theme.of(context).primaryColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             Icons.wifi,
//             color: Theme.of(context).primaryColor,
//             size: 24,
//           ),
//         ),
//         title: Text(
//           network.ssid,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(
//                   Icons.location_on,
//                   size: 14,
//                   color: Colors.grey[600],
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   '${network.location.latitude.toStringAsFixed(4)}, ${network.location.longitude.toStringAsFixed(4)}',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//             if (showDistance && userLocation != null) ...[
//               const SizedBox(height: 2),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.near_me,
//                     size: 14,
//                     color: Colors.grey[600],
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${_calculateDistance().toStringAsFixed(0)}m away',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//         trailing: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.green.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.green.withOpacity(0.3)),
//           ),
//           child: const Text(
//             'Connect',
//             style: TextStyle(
//               color: Colors.green,
//               fontWeight: FontWeight.bold,
//               fontSize: 12,
//             ),
//           ),
//         ),
//         onTap: onTap,
//       ),
//     );
//   }

//   double _calculateDistance() {
//     if (userLocation == null) return 0;
    
//     return LocationService.calculateDistance(
//       userLocation!.latitude,
//       userLocation!.longitude,
//       network.location.latitude,
//       network.location.longitude,
//     );
//   }
// }