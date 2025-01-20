# Flutter Device Info

A Flutter application that collects and displays device information.

## Device Information JSON Structure

The application collects device information in the following JSON format:

```json
{
  "deviceInfo": {
    "deviceType": "RealDevice/Emulator",
    "hardware": {
      "model": "String - Device model name",
      "brand": "String - Device brand (Android only)",
      "manufacturer": "String - Device manufacturer (Android only)",
      "hardware": "String - Hardware type (Android only)",
      "display": "String - Screen resolution (e.g., '1080x1920')",
      "physicalDevice": "Boolean - True if real device, false if emulator"
    },
    "system": {
      "platform": "String - Operating system (android/ios)",
      "version": "String - OS version",
      "locale": "String - Device locale",
      "appName": "String - Application name",
      "packageName": "String - Package identifier",
      "version": "String - App version",
      "buildNumber": "String - App build number"
    },
    "network": {
      "currentWifi": {
        "ssid": "String - WiFi network name",
        "bssid": "String - WiFi router MAC address",
        "ip": "String - Device IP address",
        "gateway": "String - Network gateway address"
      },
      "nearbyNetworks": [
        {
          "ssid": "String - Network name",
          "bssid": "String - Router MAC address",
          "level": "Integer - Signal strength"
        }
      ]
    },
    "identifiers": {
      "deviceId": "String - Unique device identifier",
      "androidId": "String - Android ID (Android only)",
      "fingerprint": "String - Device fingerprint (Android only)",
      "identifierForVendor": "String - Vendor identifier (iOS only)"
    },
    "timestamp": "String - ISO 8601 timestamp",
    "isEmulator": "Boolean - True if emulator"
  }
}
```

## Field Descriptions

### Device Type Information
- `deviceType`: Indicates whether the device is a real device or an emulator
- `isEmulator`: Boolean flag for emulator detection

### Hardware Information
- `model`: The device model name (e.g., "iPhone12,1" or "SM-G970F")
- `brand`: The consumer-visible brand (Android only, e.g., "Samsung")
- `manufacturer`: The device manufacturer (Android only)
- `hardware`: The hardware type (Android only)
- `display`: The screen resolution in pixels
- `physicalDevice`: Indicates if the app is running on a real device

### System Information
- `platform`: The operating system (android/ios)
- `version`: The operating system version
- `locale`: The device's current locale setting
- `appName`: The name of the application
- `packageName`: The package identifier (e.g., "com.example.app")
- `version`: The application version
- `buildNumber`: The application build number

### Network Information
#### Current WiFi
- `ssid`: The name of the connected WiFi network
- `bssid`: The MAC address of the connected WiFi router
- `ip`: The device's IP address on the network
- `gateway`: The network gateway address

#### Nearby Networks
- `ssid`: The name of the detected WiFi network
- `bssid`: The MAC address of the detected WiFi router
- `level`: Signal strength indicator (usually in dBm)

### Device Identifiers
- `deviceId`: A unique identifier for the device
- `androidId`: Android-specific device identifier
- `fingerprint`: Android device fingerprint
- `identifierForVendor`: iOS vendor identifier

### Metadata
- `timestamp`: The time when the information was collected (ISO 8601 format)

## Platform Specific Notes

### Android
- Additional hardware information available (brand, manufacturer, hardware)
- Android-specific identifiers (androidId, fingerprint)
- More detailed hardware information

### iOS
- Limited hardware information compared to Android
- iOS-specific identifier (identifierForVendor)
- Stricter privacy controls may affect available information

## Usage Notes

1. Some information may require specific permissions:
   - WiFi information requires location permissions
   - Device identifiers may require additional permissions

2. Information availability:
   - Some fields may return null or "Unknown" if not available
   - Emulators may have limited or simulated information
   - Different OS versions may provide different levels of information

3. Privacy considerations:
   - Some identifiers may be subject to privacy regulations
   - User consent may be required for certain information
   - Consider data protection requirements when storing device information
