import 'package:network_info_plus/network_info_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiInfoService {
  final _networkInfo = NetworkInfo();
  
  Future<Map<String, String>> getCurrentWifiInfo() async {
    final wifiName = await _networkInfo.getWifiName(); // 获取SSID
    final wifiBSSID = await _networkInfo.getWifiBSSID(); // 获取BSSID
    final wifiIP = await _networkInfo.getWifiIP(); // 获取IP地址
    final wifiGatewayIP = await _networkInfo.getWifiGatewayIP(); // 获取网关IP
    
    return {
      'ssid': wifiName ?? 'Unknown',
      'bssid': wifiBSSID ?? 'Unknown',
      'ip': wifiIP ?? 'Unknown',
      'gateway': wifiGatewayIP ?? 'Unknown',
    };
  }

  Future<List<WiFiAccessPoint>> scanWifiNetworks() async {
    // 检查权限
    final can = await WiFiScan.instance.canStartScan();
    if (can != CanStartScan.yes) {
      throw Exception('Cannot scan for wifi networks');
    }

    // 开始扫描
    await WiFiScan.instance.startScan();
    
    // 获取结果
    final results = await WiFiScan.instance.getScannedResults();
    return results;
  }
} 