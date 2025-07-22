# WiFi Connect

A Flutter mobile application that automatically scans for and connects to WiFi networks using a pre-configured database of network credentials. The app provides seamless WiFi connectivity by matching nearby networks with stored credentials.

## 🚀 Features

- **Automatic WiFi Scanning**: Detects available WiFi networks in your area
- **Smart Network Matching**: Matches detected networks with pre-stored credentials
- **Cross-Platform Support**: Works on both Android and iOS
- **Location-Based Discovery**: Uses GPS location to find nearby networks (iOS)
- **One-Tap Connection**: Simple interface for quick WiFi connection
- **Manual Connection Support**: Provides network details for manual setup on iOS
- **Modern UI**: Clean, animated interface with smooth user experience

## 📱 Screenshots
![WhatsApp Image 2025-07-22 at 22 53 48_2dc17e36](https://github.com/user-attachments/assets/c9d922c8-ada4-4e0f-88a0-38f4f8205ba1)



## 🏗️ Architecture

The app follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── main.dart                    # Application entry point
├── models/                      # Data models
│   └── wifi_network.dart        # WiFi network model with encryption/decryption
├── services/                    # Business logic and external APIs
│   ├── wifi_database_service.dart    # Local database operations
│   ├── wifi_scanner_service.dart     # Platform-specific WiFi operations
│   └── permission_service.dart       # Permission handling and location services
├── screens/                     # UI screens
│   └── home_screen.dart         # Main application screen
└── widgets/                     # Reusable UI components
    └── wifi_network_tile.dart   # Custom network list item
```

### Architecture Components

#### **Models Layer**
- `WifiNetwork`: Contains network information (SSID, password, location, encryption details)
- Handles password encryption/decryption for security

#### **Services Layer**
- `WiFiDatabaseService`: Manages local database of WiFi networks with CRUD operations
- `WiFiScannerService`: Handles platform-specific WiFi scanning and connection
- `PermissionService`: Manages app permissions and location services

#### **UI Layer**
- `HomeScreen`: Main interface with state management for scanning and connection
- `WiFiNetworkTile`: Reusable component for displaying network information
- Modern Material Design with animations and smooth transitions

## 🔧 Platform-Specific Behavior

### Android
- **Direct WiFi Scanning**: Uses native Android WiFi APIs to scan for available networks
- **Automatic Connection**: Programmatically connects to selected networks
- **Real-time Network Detection**: Shows actual nearby WiFi access points

### iOS
- **Location-Based Discovery**: Uses GPS coordinates to find networks within 50-meter radius
- **Manual Connection**: Provides network credentials for manual setup in iOS Settings
- **Clipboard Integration**: Automatically copies passwords for easy manual entry

## 🔐 Permissions & APIs

### Required Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- WiFi and Network Access -->
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />

<!-- Location Services (required for WiFi scanning on Android 6+) -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

<!-- Background Location (if needed) -->
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<!-- Location Services -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to find nearby WiFi networks from our database.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Location access helps find WiFi networks near your current position.</string>

<!-- Network Information (if using network APIs) -->
<key>NSLocalNetworkUsageDescription</key>
<string>This app accesses local network to manage WiFi connections.</string>
```

### Platform APIs Used

#### Android Native APIs
- **WifiManager**: For WiFi state management and network operations
- **ConnectivityManager**: For network connectivity monitoring
- **LocationManager**: For GPS-based location services
- **WifiConfiguration**: For network connection configuration

#### iOS Native APIs
- **CoreLocation**: For GPS location services
- **NetworkExtension** (limited): For network information
- **SystemConfiguration**: For network reachability

## 📋 Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (2.17+)
- Android Studio / Xcode for platform-specific development
- Physical devices for testing (WiFi functionality doesn't work in simulators)

## 🛠️ Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/promptcue.git
cd promptcue
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure permissions**
   - Add required permissions to `android/app/src/main/AndroidManifest.xml` (Android)
   - Add usage descriptions to `ios/Runner/Info.plist` (iOS)

4. **Setup WiFi Database**
   - Configure your WiFi networks database in `WiFiDatabaseService`
   - Add network credentials (SSID, password, location data)

5. **Run the app**
```bash
flutter run
```

## 🔒 Security Considerations

- **Password Encryption**: All WiFi passwords are encrypted before storage
- **Local Storage**: Network credentials stored securely on device
- **Permission Handling**: Graceful permission requests with user explanations
- **No Cloud Storage**: All data remains on the user's device

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Development Notes

### State Management
- Uses Flutter's built-in `StatefulWidget` with clear state enums
- Animated state transitions for better UX
- Proper error handling and user feedback

### Error Handling
- Comprehensive try-catch blocks for all async operations
- User-friendly error messages
- Graceful fallbacks for permission denials

### Testing
- Test on physical devices (WiFi APIs don't work in emulators)
- Test permission flows on both platforms
- Verify location services integration

## 🐛 Known Issues

- iOS limitations prevent direct WiFi connections (platform restriction)
- Android 10+ requires location permissions for WiFi scanning
- Background scanning may be limited by platform power management


**Built with ❤️ using Flutter**
