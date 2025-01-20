import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  // 获取所有需要的权限列表
  List<Permission> _getRequiredPermissions() {
    List<Permission> permissions = [
      Permission.location, // WiFi扫描需要
    ];

    if (Platform.isAndroid) {
      permissions.addAll([
        Permission.phone,
        Permission.nearbyWifiDevices,
      ]);
    }

    if (Platform.isIOS) {
      permissions.add(Permission.locationWhenInUse);
    }

    return permissions;
  }

  // 获取当前权限状态
  Future<Map<Permission, PermissionStatus>> getPermissionStatus() async {
    final permissions = _getRequiredPermissions();
    Map<Permission, PermissionStatus> statuses = {};

    for (var permission in permissions) {
      statuses[permission] = await permission.status;
    }

    return statuses;
  }

  // 请求指定权限
  Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }

  // 请求所有权限
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    final permissions = _getRequiredPermissions();
    Map<Permission, PermissionStatus> statuses = {};

    for (var permission in permissions) {
      statuses[permission] = await permission.request();
    }

    return statuses;
  }

  // 检查单个权限
  Future<bool> checkPermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  // 打开应用设置
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
} 