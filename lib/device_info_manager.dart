import 'dart:convert';
import 'dart:io';

import 'package:carrier_info/carrier_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:sim_card_info/sim_card_info.dart';

import 'wifi_info.dart';

class DeviceInfoManager {
  static final DeviceInfoManager _instance = DeviceInfoManager._internal();

  factory DeviceInfoManager() => _instance;

  DeviceInfoManager._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final WifiInfoService _wifiInfo = WifiInfoService();

  // 获取硬件信息
  Future<Map<String, dynamic>> getHardwareInfo() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        'model': androidInfo.model,
        'brand': androidInfo.brand,
        'manufacturer': androidInfo.manufacturer,
        'hardware': androidInfo.hardware,
        'display': '${androidInfo.displayMetrics.widthPx}x${androidInfo.displayMetrics.heightPx}',
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
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
    };
  }

  // 获取移动网络信息
  Future<Map<String, dynamic>> getMobileNetworkInfo() async {
    try {
      final simInfos = await SimCardInfo().getSimInfo();
      Map<dynamic, dynamic> carrierData = {};

      if (Platform.isAndroid) {
        final androidInfo = await CarrierInfo.getAndroidInfo();
        debugPrint('$androidInfo');
        carrierData.addAll(androidInfo?.toMap() ?? {});
      } else if (Platform.isIOS) {
        final iosInfo = await CarrierInfo.getIosInfo();
        carrierData.addAll(iosInfo.toMap());
        debugPrint('$iosInfo');
      }
      return {
        // 运营商信息
        ...carrierData,

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
    List<dynamic> nearbyNetworks = [];
    try {
      final networks = await _wifiInfo.scanWifiNetworks();
      nearbyNetworks = networks
          .map((network) => {
                'ssid': network.ssid,
                'bssid': network.bssid,
                'level': network.level,
              })
          .toList();
    } catch (e) {
      print('Failed to scan networks: $e');
    }

    return {
      'currentWifi': wifiInfo,
      'mobileNetwork': mobileInfo,
      'nearbyNetworks': nearbyNetworks,
    };
  }

  // 获取设备标识符
  Future<Map<String, dynamic>> getDeviceIdentifiers() async {
    String? deviceId = await PlatformDeviceId.getDeviceId;

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        'deviceId': deviceId,
        'androidId': androidInfo.id,
        'fingerprint': androidInfo.fingerprint,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return {
        'deviceId': deviceId,
        'identifierForVendor': iosInfo.identifierForVendor,
      };
    }
    return {'deviceId': deviceId};
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
      'deviceType': {
        'isRealDevice': isReal,
        'deviceTypeDesc': isReal ? 'RealDevice' : 'Emulator',
      },
      'hardware': await getHardwareInfo(),
      'system': await getSystemInfo(),
      'network': await getNetworkInfo(),
      'identifiers': await getDeviceIdentifiers(),
    };
  }

  // 生成完整的JSON数据
  Future<Map<String, dynamic>> generateFullDeviceInfo() async {
    final Map<String, dynamic> allInfo = await getAllDeviceInfo();
    final isReal = allInfo['deviceType']['isRealDevice'];

    return {
      "deviceInfo": {
        "deviceType": isReal ? "RealDevice" : "Emulator",
        "hardware": allInfo['hardware'],
        "system": allInfo['system'],
        "network": allInfo['network'],
        "identifiers": allInfo['identifiers'],
        "timestamp": DateTime.now().toIso8601String(),
        "isEmulator": !isReal,
      }
    };
  }

  // 将设备信息转换为JSON字符串
  Future<String> getDeviceInfoAsJson() async {
    final deviceInfo = await generateFullDeviceInfo();
    return jsonEncode(deviceInfo);
  }
}
