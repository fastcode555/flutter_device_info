import 'dart:convert';

import 'package:flutter/material.dart';

import 'device_info_manager.dart';

class DeviceInfoPage extends StatelessWidget {
  const DeviceInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备信息'),
        actions: [
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
                _buildSection('硬件信息', data['hardware']),
                _buildSection('系统信息', data['system']),
                _buildSection('网络信息', data['network']),
                _buildSection('设备标识', data['identifiers']),
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
}
