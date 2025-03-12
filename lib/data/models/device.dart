// lib/data/models/device.dart

import 'package:flutter/material.dart';
import 'package:smart_device_manager/data/models/device_property.dart';
import 'package:smart_device_manager/data/models/device_tsl.dart';
import 'package:smart_device_manager/data/repositories/tsl_repository.dart';

class Device {
  final String id;
  final String name;
  final String type;
  final String room;
  final IconData iconData;
  String status;
  final Map<String, dynamic> properties = {}; // Stores current property values

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.room,
    required this.iconData,
    this.status = 'offline',
  });

  // Get the TSL definition for this device based on its type
  DeviceTSL get tsl {
    final tslRepository = TSLRepository();
    return tslRepository.getTSLDefinitions()[type] ??
        tslRepository
            .getDefaultTSL(); // Fallback to a default if type not found
  }

  // Check if device is online
  bool get isOnline => status == 'online';

  // Set device online/offline status
  void setStatus(bool online) {
    status = online ? 'online' : 'offline';
    // Here you would also call your backend API to update the status
  }

  // Get a property value with fallback to the default from TSL
  dynamic getProperty(String identifier) {
    // If the property exists in our local state, return it
    if (properties.containsKey(identifier)) {
      return properties[identifier];
    }

    // Otherwise, find the default value from the TSL definition
    try {
      final property = tsl.properties.firstWhere(
        (p) => p.identifier == identifier,
        orElse: () => throw Exception('Property not found: $identifier'),
      );
      return property.value;
    } catch (e) {
      debugPrint('Error getting property $identifier: $e');
      return null;
    }
  }

  // Set a property value and optionally update the backend
  Future<bool> setProperty(String identifier, dynamic value,
      {bool updateBackend = true}) async {
    try {
      // Validate the value against the property's constraints
      final property = tsl.properties.firstWhere(
        (p) => p.identifier == identifier,
        orElse: () => throw Exception('Property not found: $identifier'),
      );

      // Perform type validation and range checking
      if (!_isValidPropertyValue(property, value)) {
        throw Exception('Invalid value for property $identifier: $value');
      }

      // Update local state
      properties[identifier] = value;

      // Update backend if requested
      if (updateBackend) {
        // This would be an async call to your backend API
        // await deviceService.updateDeviceProperty(id, identifier, value);

        // For now, we'll just simulate success
        return Future.delayed(Duration(milliseconds: 300), () => true);
      }
      return true;
    } catch (e) {
      debugPrint('Error setting property $identifier: $e');
      return false;
    }
  }

  // Check if a value is valid for a given property
  bool _isValidPropertyValue(DeviceProperty property, dynamic value) {
    switch (property.dataType) {
      case 'boolean':
        return value is bool;

      case 'integer':
        if (value is! int && value is! double) return false;
        final numValue = (value is int) ? value.toDouble() : value;
        final specs = property.specs;

        if (specs != null) {
          final min = specs['min'] as double?;
          final max = specs['max'] as double?;

          if (min != null && numValue < min) return false;
          if (max != null && numValue > max) return false;
        }
        return true;

      case 'float':
        if (value is! double && value is! int) return false;
        final numValue = value.toDouble();
        final specs = property.specs;

        if (specs != null) {
          final min = specs['min'] as double?;
          final max = specs['max'] as double?;

          if (min != null && numValue < min) return false;
          if (max != null && numValue > max) return false;
        }
        return true;

      case 'enum':
        if (value is! String) return false;
        final specs = property.specs;

        if (specs != null && specs.containsKey('options')) {
          final options = specs['options'] as List<dynamic>;
          return options.contains(value);
        }
        return true;

      default:
        return true; // Other types are assumed valid
    }
  }

  // Convert to a map representation (useful for APIs)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'room': room,
      'status': status,
      'properties': Map<String, dynamic>.from(properties),
    };
  }

  // Create a copy of this device with optional parameter overrides
  Device copyWith({
    String? id,
    String? name,
    String? type,
    String? room,
    IconData? iconData,
    String? status,
    Map<String, dynamic>? properties,
  }) {
    final device = Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      room: room ?? this.room,
      iconData: iconData ?? this.iconData,
      status: status ?? this.status,
    );

    if (properties != null) {
      device.properties.addAll(properties);
    } else {
      device.properties.addAll(this.properties);
    }

    return device;
  }
}
