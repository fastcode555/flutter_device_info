# Flutter 设备信息采集

一个用于采集和显示设备信息的 Flutter 应用。

## 设备信息 JSON 结构

应用程序采集的设备信息将以以下 JSON 格式返回：

```json
{
  "deviceInfo": {
    "deviceType": "RealDevice/Emulator - 真机/模拟器",
    "hardware": {
      "model": "String - 设备型号",
      "brand": "String - 设备品牌（仅 Android）",
      "manufacturer": "String - 设备制造商（仅 Android）",
      "hardware": "String - 硬件类型（仅 Android）",
      "display": "String - 屏幕分辨率（例如：'1080x1920'）",
      "physicalDevice": "Boolean - true 表示真机，false 表示模拟器"
    },
    "system": {
      "platform": "String - 操作系统（android/ios）",
      "version": "String - 系统版本",
      "locale": "String - 设备语言环境",
      "appName": "String - 应用名称",
      "packageName": "String - 包标识符",
      "version": "String - 应用版本",
      "buildNumber": "String - 应用构建号"
    },
    "network": {
      "currentWifi": {
        "ssid": "String - WiFi 网络名称",
        "bssid": "String - WiFi 路由器 MAC 地址",
        "ip": "String - 设备 IP 地址",
        "gateway": "String - 网关地址"
      },
      "nearbyNetworks": [
        {
          "ssid": "String - 网络名称",
          "bssid": "String - 路由器 MAC 地址",
          "level": "Integer - 信号强度"
        }
      ]
    },
    "identifiers": {
      "deviceId": "String - 设备唯一标识符",
      "androidId": "String - Android ID（仅 Android）",
      "fingerprint": "String - 设备指纹（仅 Android）",
      "identifierForVendor": "String - 供应商标识符（仅 iOS）"
    },
    "timestamp": "String - ISO 8601 时间戳",
    "isEmulator": "Boolean - true 表示模拟器"
  }
}
```

## 字段说明

### 设备类型信息
- `deviceType`：表示设备是真机还是模拟器
- `isEmulator`：模拟器检测标志

### 硬件信息
- `model`：设备型号（例如："iPhone12,1" 或 "SM-G970F"）
- `brand`：消费者可见的品牌（仅 Android，例如："Samsung"）
- `manufacturer`：设备制造商（仅 Android）
- `hardware`：硬件类型（仅 Android）
- `display`：屏幕分辨率（像素）
- `physicalDevice`：表示应用是否运行在真实设备上

### 系统信息
- `platform`：操作系统（android/ios）
- `version`：操作系统版本
- `locale`：设备当前的语言环境设置
- `appName`：应用程序名称
- `packageName`：包标识符（例如："com.example.app"）
- `version`：应用程序版本
- `buildNumber`：应用程序构建号

### 网络信息
#### 当前 WiFi
- `ssid`：已连接的 WiFi 网络名称
- `bssid`：已连接的 WiFi 路由器 MAC 地址
- `ip`：设备在网络中的 IP 地址
- `gateway`：网络网关地址

#### 周边网络
- `ssid`：检测到的 WiFi 网络名称
- `bssid`：检测到的 WiFi 路由器 MAC 地址
- `level`：信号强度指示器（通常以 dBm 为单位）

### 设备标识符
- `deviceId`：设备的唯一标识符
- `androidId`：Android 特有的设备标识符
- `fingerprint`：Android 设备指纹
- `identifierForVendor`：iOS 供应商标识符

### 元数据
- `timestamp`：信息采集时的时间戳（ISO 8601 格式）

## 平台特定说明

### Android 平台
- 提供额外的硬件信息（品牌、制造商、硬件类型）
- Android 特有的标识符（androidId、fingerprint）
- 更详细的硬件信息

### iOS 平台
- 相比 Android 硬件信息较少
- iOS 特有的标识符（identifierForVendor）
- 更严格的隐私控制可能影响信息的可用性

## 使用注意事项

1. 部分信息需要特定权限：
   - WiFi 信息需要位置权限
   - 设备标识符可能需要额外权限

2. 信息可用性：
   - 某些字段可能返回 null 或 "Unknown"
   - 模拟器可能提供有限或模拟的信息
   - 不同系统版本可能提供不同级别的信息

3. 隐私考虑：
   - 某些标识符可能受隐私法规约束
   - 某些信息的获取可能需要用户同意
   - 存储设备信息时需考虑数据保护要求 