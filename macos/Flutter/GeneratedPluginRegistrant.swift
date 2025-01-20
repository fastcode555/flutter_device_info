//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import device_info_plus
import network_info_plus
import package_info_plus
import sim_card_info

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  NetworkInfoPlusPlugin.register(with: registry.registrar(forPlugin: "NetworkInfoPlusPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  SimCardInfoPlugin.register(with: registry.registrar(forPlugin: "SimCardInfoPlugin"))
}
