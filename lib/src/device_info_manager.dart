import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_card_info/sim_card_info.dart';

import 'permission_manager.dart';
import 'wifi_info.dart';

class DeviceInfoManager {
  static DeviceInfoManager? _instance;

  factory DeviceInfoManager() => _getInstance();

  static DeviceInfoManager get instance => _getInstance();

  DeviceInfoManager._internal();

  static DeviceInfoManager _getInstance() {
    _instance ??= DeviceInfoManager._internal();
    return _instance!;
  }

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final WifiInfoService _wifiInfo = WifiInfoService();
  final PermissionManager _permissionManager = PermissionManager();

  // 获取硬件信息
  Future<Map<String, dynamic>> getHardwareInfo() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        'model': androidInfo.model,
        'brand': androidInfo.brand,
        'manufacturer': androidInfo.manufacturer,
        'hardware': androidInfo.hardware,
        'display': androidInfo.display,
        'physicalDevice': androidInfo.isPhysicalDevice,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return {
        'model': iosInfo.model,
        'name': iosInfo.name,
        'systemName': iosInfo.systemName,
        'utsname': iosInfo.utsname.machine,
        'physicalDevice': iosInfo.isPhysicalDevice,
      };
    }
    return {};
  }

  // 获取系统信息
  Future<Map<String, dynamic>> getSystemInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'locale': Platform.localeName,
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'package_version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
    };
  }

  // 获取移动网络信息
  Future<Map<String, dynamic>> getMobileNetworkInfo() async {
    try {
      // 检查权限
      if (Platform.isAndroid && !await _permissionManager.checkPermission(Permission.phone)) {
        return {};
      }
      final simInfos = await SimCardInfo().getSimInfo();
      return {
        'sim_info': simInfos?.map((v) => v.toJson()).toList(),
      };
    } catch (e) {
      print('Failed to get mobile network info: $e');
      return {
        'error': 'Failed to get mobile network info',
        'errorDetails': e.toString(),
      };
    }
  }

  // 获取网络信息
  Future<Map<String, dynamic>> getNetworkInfo() async {
    final wifiInfo = await _wifiInfo.getCurrentWifiInfo();
    final mobileInfo = await getMobileNetworkInfo();
    Map<String, dynamic> result = {};

    // 只添加成功获取的信息
    if (!wifiInfo.containsKey('error')) {
      result['currentWifi'] = wifiInfo;
    }

    if (!mobileInfo.containsKey('error')) {
      result['mobileNetwork'] = mobileInfo;
    }

    List<dynamic> nearbyNetworks = [];
    try {
      if (await _permissionManager.checkPermission(Permission.location)) {
        final networks = await _wifiInfo.scanWifiNetworks();
        nearbyNetworks = networks
            .map((network) => {
                  'ssid': network.ssid,
                  'bssid': network.bssid,
                  'level': network.level,
                })
            .toList();
        result['nearbyNetworks'] = nearbyNetworks;
      }
    } catch (e) {
      print('Failed to scan networks: $e');
    }

    return result;
  }

  // 获取设备标识符
  Future<Map<String, dynamic>> getDeviceIdentifiers() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        'deviceId': androidInfo.id,
        'fingerprint': androidInfo.fingerprint,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return {
        'deviceId': iosInfo.identifierForVendor,
      };
    }
    return {};
  }

  // 判断是否为真实设备
  Future<bool> isRealDevice() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.isPhysicalDevice;
    }
    return false;
  }

  // 获取所有信息
  Future<Map<String, dynamic>> getAllDeviceInfo() async {
    final isReal = await isRealDevice();
    return {
      'hardware': await getHardwareInfo(),
      'system': await getSystemInfo(),
      'network': await getNetworkInfo(),
      'identifiers': await getDeviceIdentifiers(),
    };
  }

  // 生成完整的JSON数据
  Future<Map<String, dynamic>> generateFullDeviceInfo() async {
    final Map<String, dynamic> allInfo = await getAllDeviceInfo();

    return {
      "deviceInfo": {
        "hardware": allInfo['hardware'],
        "system": allInfo['system'],
        "network": allInfo['network'],
        "identifiers": allInfo['identifiers'],
        "timestamp": DateTime.now().toIso8601String(),
      }
    };
  }

  // 将设备信息转换为JSON字符串
  Future<String> getDeviceInfoAsJson() async {
    final deviceInfo = await generateFullDeviceInfo();
    return jsonEncode(deviceInfo);
  }

  void requestPermissions() async {
    final permissions = getRequiredPermissions();
    for (final permission in permissions) {
      final status = await PermissionManager().requestPermission(permission);
      if (status.isGranted) {
        debugPrint('request permission successd ${permission}');
      }
    }
  }

  // 获取所有需要的权限列表
  List<Permission> getRequiredPermissions() {
    List<Permission> permissions = [
      Permission.location, // WiFi扫描需要
    ];

    if (Platform.isAndroid) {
      permissions.addAll([
        Permission.phone, // 用于获取移动网络信息
      ]);
    }

    if (Platform.isIOS) {
      permissions.add(Permission.locationWhenInUse); // iOS定位权限
    }

    return permissions;
  }

  // 获取权限描述
  Map<Permission, String> getPermissionDescriptions() {
    return {
      Permission.location: '用于获取WiFi信息和扫描周边网络',
      Permission.phone: '用于获取移动网络和SIM卡信息',
      Permission.nearbyWifiDevices: '用于扫描周边WiFi网络（Android 13及以上需要）',
      Permission.locationWhenInUse: '用于获取WiFi信息（iOS需要）',
    };
  }
}
