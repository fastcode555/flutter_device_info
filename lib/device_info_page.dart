import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'device_info_manager.dart';
import 'permission_manager.dart';

class DeviceInfoPage extends StatelessWidget {
  const DeviceInfoPage({super.key});

  // 申请权限并返回新的状态
  Future<PermissionStatus> _requestPermission(Permission permission) async {
    final status = await PermissionManager().requestPermission(permission);
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备信息'),
        actions: [
          IconButton(
            icon: const Icon(Icons.security),
            tooltip: '权限设置',
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) => FutureBuilder<Map<Permission, PermissionStatus>>(
                    future: PermissionManager().getPermissionStatus(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const AlertDialog(
                          title: Text('加载中...'),
                          content: CircularProgressIndicator(),
                        );
                      }
                      
                      return AlertDialog(
                        title: const Text('权限状态'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: snapshot.data!.entries.map((entry) {
                              return ListTile(
                                title: Text(_getPermissionName(entry.key)),
                                subtitle: Text(_getStatusDescription(entry.value)),
                                leading: Icon(
                                  entry.value.isGranted ? Icons.check_circle : Icons.error,
                                  color: entry.value.isGranted ? Colors.green : Colors.red,
                                ),
                                trailing: entry.value.isGranted
                                    ? null
                                    : TextButton(
                                        onPressed: () async {
                                          if (entry.value.isPermanentlyDenied) {
                                            await PermissionManager().openAppSettings();
                                          } else {
                                            final newStatus = await _requestPermission(entry.key);
                                            setState(() {
                                              snapshot.data![entry.key] = newStatus;
                                            });
                                          }
                                        },
                                        child: Text(
                                          entry.value.isPermanentlyDenied ? '去设置' : '授权',
                                          style: const TextStyle(color: Colors.blue),
                                        ),
                                      ),
                              );
                            }).toList(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('关闭'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () async {
              final jsonData = await DeviceInfoManager().getDeviceInfoAsJson();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('JSON数据'),
                  content: SingleChildScrollView(
                    child: SelectableText(
                      const JsonEncoder.withIndent('  ').convert(jsonDecode(jsonData)),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: DeviceInfoManager().getAllDeviceInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              (context as Element).markNeedsBuild();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDeviceTypeSection(data['deviceType']),
                if (data['hardware'] != null) _buildSection('硬件信息', data['hardware']),
                if (data['system'] != null) _buildSection('系统信息', data['system']),
                if (data['network'] != null) _buildSection('网络信息', data['network']),
                if (data['identifiers'] != null) _buildSection('设备标识', data['identifiers']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceTypeSection(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: data['isRealDevice'] ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              data['isRealDevice'] ? Icons.phone_android : Icons.computer,
              size: 32,
              color: data['isRealDevice'] ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 16),
            Text(
              '当前设备类型: ${data['deviceTypeDesc']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: data['isRealDevice'] ? Colors.green[900] : Colors.orange[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...data.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.value?.toString() ?? 'N/A',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.location:
        return '位置信息';
      case Permission.phone:
        return '电话信息';
      case Permission.nearbyWifiDevices:
        return 'WiFi扫描';
      case Permission.locationWhenInUse:
        return '使用期间的位置信息';
      default:
        return permission.toString();
    }
  }

  String _getStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '已授权';
      case PermissionStatus.denied:
        return '已拒绝';
      case PermissionStatus.permanentlyDenied:
        return '永久拒绝';
      case PermissionStatus.restricted:
        return '受限制';
      case PermissionStatus.limited:
        return '部分授权';
      default:
        return '未知状态';
    }
  }
}
