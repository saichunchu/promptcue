// import '../models/wifi_network.dart';
// import 'dart:math' as math;

// class WiFiDatabase {
//   static const List<Map<String, dynamic>> _wifiData = [
//     {
//       "ssid": "Cafe_JavaHouse",
//       "password_encrypted": "c2VjcmV0MTIz",
//       "location": {"latitude": 17.385044, "longitude": 78.486671} // Banjara Hills
//     },
//     {
//       "ssid": "ScrapGenie_Office", 
//       "password_encrypted": "c2NnQGRtaW4yMDI0",
//       "location": {"latitude": 17.440674, "longitude": 78.380722} // Gachibowli
//     },
    
//     {
//       "ssid": "PromptCue_WiFi",
//       "password_encrypted": "UFBDdWUtU3VwZXIxIQ==",
//       "location": {"latitude": 17.425926, "longitude": 78.335006} // HITEC City
//     },
//     {
//       "ssid": "InderHome_5G",
//       "password_encrypted": "SW5kZXIxMjM0NQ==",
//       "location": {"latitude": 17.406498, "longitude": 78.476425} // Jubilee Hills
//     },
//     {
//       "ssid": "Charminar_Cafe",
//       "password_encrypted": "Y2hhcm1pbmFyMTIz",
//       "location": {"latitude": 17.361564, "longitude": 78.474747} // Charminar area
//     },
//     {
//       "ssid": "Cyber_Tower_WiFi",
//       "password_encrypted": "Y3liZXJ0b3dlcjQ1Ng==",
//       "location": {"latitude": 17.442139, "longitude": 78.381657} // Cyberabad
//     },
//     {
//       "ssid": "SecCity_Network",
//       "password_encrypted": "c2VjY2l0eTc4OQ==",
//       "location": {"latitude": 17.417985, "longitude": 78.426781} // Secunderabad
//     },
//     {
//       "ssid": "Kondapur_Home",
//       "password_encrypted": "a29uZGFwdXIxMjM=",
//       "location": {"latitude": 17.461487, "longitude": 78.364441} // Kondapur
//     },
//     {
//       "ssid": "Madhapur_Office",
//       "password_encrypted": "bWFkaGFwdXIyMDI0",
//       "location": {"latitude": 17.448147, "longitude": 78.391815} // Madhapur
//     },
//     {
//       "ssid": "Tank_Bund_Wifi",
//       "password_encrypted": "dGFua2J1bmQxMjM=",
//       "location": {"latitude": 17.415933, "longitude": 78.470654} // Tank Bund
//     }
//   ];
//   static List<WiFiNetwork> getNetworksWithCurrentLocation(
//   double userLatitude,
//   double userLongitude, {
//   double radiusInMeters = 50.0,
// }) {
//   // Create test networks around your current location
//   final currentLocationNetworks = [
//     {
//       "ssid": "MyCurrentWiFi",
//       "password_encrypted": "bXljdXJyZW50d2lmaQ==", // base64 for "mycurrentwifi"
//       "location": {"latitude": 17.485079074271372, "longitude":78.39497414734171}
//     },
//     {
//       "ssid": "NearbyNetwork1", 
//       "password_encrypted": "bmVhcmJ5bmV0MQ==",
//       "location": {"latitude": userLatitude + 0.0001, "longitude": userLongitude + 0.0001} // ~11m away
//     },
//     {
//       "ssid": "NearbyNetwork2",
//       "password_encrypted": "bmVhcmJ5bmV0Mg==", 
//       "location": {"latitude": userLatitude - 0.0001, "longitude": userLongitude - 0.0001} // ~11m away
//     },
//   ];

//   // Combine with existing data
//   final allData = [..._wifiData, ...currentLocationNetworks];

//   return allData
//       .map((data) => WiFiNetwork.fromJson(data))
//       .where((network) {
//     final distance = _calculateDistance(
//       userLatitude,
//       userLongitude,
//       network.location.latitude,
//       network.location.longitude,
//     );
//     return distance <= radiusInMeters;
//   }).toList();
// }



//   static List<WiFiNetwork> getAllNetworks() {
//     return _wifiData.map((data) => WiFiNetwork.fromJson(data)).toList();
//   }

//   static WiFiNetwork? getNetworkBySSID(String ssid) {
//     try {
//       final data = _wifiData.firstWhere((network) => network['ssid'] == ssid);
//       return WiFiNetwork.fromJson(data);
//     } catch (e) {
//       return null;
//     }
//   }

//   static List<WiFiNetwork> getNetworksBySSIDs(List<String> ssids) {
//     return _wifiData
//         .where((network) => ssids.contains(network['ssid']))
//         .map((data) => WiFiNetwork.fromJson(data))
//         .toList();
//   }

//   static List<WiFiNetwork> getNearbyNetworks(
//     double userLatitude,
//     double userLongitude, {
//     double radiusInMeters = 100.0,
//   }) {
//     return _wifiData
//         .map((data) => WiFiNetwork.fromJson(data))
//         .where((network) {
//       final distance = _calculateDistance(
//         userLatitude,
//         userLongitude,
//         network.location.latitude,
//         network.location.longitude,
//       );
//       return distance <= radiusInMeters;
//     }).toList();
//   }

//   // Fixed distance calculation using proper Haversine formula
//   static double _calculateDistance(
//     double lat1,
//     double lon1,
//     double lat2,
//     double lon2,
//   ) {
//     const double earthRadius = 6371000; // meters
//     final double dLat = _degreesToRadians(lat2 - lat1);
//     final double dLon = _degreesToRadians(lon2 - lon1);
    
//     final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
//         math.sin(dLon / 2) * math.sin(dLon / 2);
    
//     final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//     return earthRadius * c;
//   }

//   static double _degreesToRadians(double degrees) {
//     return degrees * (math.pi / 180);
//   }

//   // Helper method to get networks with distances for debugging
//   static List<Map<String, dynamic>> getNearbyNetworksWithDistances(
//     double userLatitude,
//     double userLongitude, {
//     double radiusInMeters = 1000.0,
//   }) {
//     return _wifiData
//         .map((data) {
//       final network = WiFiNetwork.fromJson(data);
//       final distance = _calculateDistance(
//         userLatitude,
//         userLongitude,
//         network.location.latitude,
//         network.location.longitude,
//       );
//       return {
//         'network': network,
//         'distance': distance,
//         'withinRadius': distance <= radiusInMeters,
//       };
//     }).toList();
//   }

//   // Method to add test network at current location for debugging
//   static List<WiFiNetwork> getNetworksWithTestLocation(
//     double userLatitude,
//     double userLongitude, {
//     double radiusInMeters = 50.0,
//   }) {
//     // Add a test network at user's current location
//     final testData = [
//       ..._wifiData,
//       {
//         "ssid": "TestNetwork_CurrentLocation",
//         "password_encrypted": "dGVzdGxvY2F0aW9u",
//         "location": {"latitude": userLatitude, "longitude": userLongitude}
//       },
//     ];

//     return testData
//         .map((data) => WiFiNetwork.fromJson(data))
//         .where((network) {
//       final distance = _calculateDistance(
//         userLatitude,
//         userLongitude,
//         network.location.latitude,
//         network.location.longitude,
//       );
//       return distance <= radiusInMeters;
//     }).toList();
//   }
// }

