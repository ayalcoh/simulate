// lib/data/models/device_tsl.dart

import 'package:smart_device_manager/data/models/device_property.dart';

class DeviceTSL {
  final String deviceType;
  final List<DeviceProperty> properties;

  DeviceTSL({
    required this.deviceType,
    required this.properties,
  });

  // Create from JSON (useful when receiving from API)
  factory DeviceTSL.fromJson(Map<String, dynamic> json) {
    return DeviceTSL(
      deviceType: json['deviceType'],
      properties: (json['properties'] as List)
          .map((propertyJson) => DeviceProperty.fromJson(propertyJson))
          .toList(),
    );
  }

  // Convert to JSON (useful when sending to API)
  Map<String, dynamic> toJson() {
    return {
      'deviceType': deviceType,
      'properties': properties.map((property) => property.toJson()).toList(),
    };
  }
}
