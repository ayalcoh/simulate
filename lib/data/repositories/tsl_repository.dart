// lib/data/repositories/tsl_repository.dart

import 'package:smart_device_manager/data/models/device_property.dart';
import 'package:smart_device_manager/data/models/device_tsl.dart';

class TSLRepository {
  // Singleton pattern
  static final TSLRepository _instance = TSLRepository._internal();

  factory TSLRepository() {
    return _instance;
  }

  TSLRepository._internal();

  // Get predefined TSL definitions for device types
  Map<String, DeviceTSL> getTSLDefinitions() {
    return {
      'Light': DeviceTSL(
        deviceType: 'Light',
        properties: [
          DeviceProperty(
            identifier: 'power',
            name: 'Power',
            dataType: 'boolean',
            value: false,
          ),
          DeviceProperty(
            identifier: 'brightness',
            name: 'Brightness',
            dataType: 'integer',
            value: 50,
            specs: {'min': 0.0, 'max': 100.0, 'step': 1.0},
          ),
          DeviceProperty(
            identifier: 'color_temp',
            name: 'Color Temperature',
            dataType: 'integer',
            value: 3000,
            specs: {'min': 2700.0, 'max': 6500.0, 'step': 100.0},
          ),
          DeviceProperty(
            identifier: 'color',
            name: 'Color',
            dataType: 'string',
            value: '#FFFFFF',
          ),
        ],
      ),
      'Sensor': DeviceTSL(
        deviceType: 'Sensor',
        properties: [
          DeviceProperty(
            identifier: 'active',
            name: 'Active',
            dataType: 'boolean',
            value: true,
          ),
          DeviceProperty(
            identifier: 'reading',
            name: 'Reading',
            dataType: 'float',
            value: 23.5,
            specs: {'unit': 'C'},
          ),
          DeviceProperty(
            identifier: 'threshold',
            name: 'Alert Threshold',
            dataType: 'float',
            value: 30.0,
            specs: {'min': 0.0, 'max': 100.0, 'step': 0.5, 'unit': 'C'},
          ),
          DeviceProperty(
            identifier: 'alert_mode',
            name: 'Alert Mode',
            dataType: 'enum',
            value: 'Notification',
            specs: {
              'options': ['None', 'Notification', 'Alarm']
            },
          ),
        ],
      ),
      'Controller': DeviceTSL(
        deviceType: 'Controller',
        properties: [
          DeviceProperty(
            identifier: 'power',
            name: 'Power',
            dataType: 'boolean',
            value: false,
          ),
          DeviceProperty(
            identifier: 'mode',
            name: 'Mode',
            dataType: 'enum',
            value: 'Standard',
            specs: {
              'options': ['Standard', 'Eco', 'Boost', 'Auto']
            },
          ),
          DeviceProperty(
            identifier: 'active_scenario',
            name: 'Active Scenario',
            dataType: 'enum',
            value: 'None',
            specs: {
              'options': [
                'None',
                'Ocean',
                'Forest',
                'Sunshine',
                'Evening',
                'Party'
              ],
              'has_library': true, // Flag to indicate this has a library
            },
          ),
          DeviceProperty(
            identifier: 'brightness',
            name: 'Brightness',
            dataType: 'integer',
            value: 50,
            specs: {'min': 0.0, 'max': 100.0, 'step': 1.0},
          ),
          DeviceProperty(
            identifier: 'color',
            name: 'Color',
            dataType: 'string',
            value: '#FFFFFF',
          ),
          DeviceProperty(
            identifier: 'animation',
            name: 'Animation',
            dataType: 'enum',
            value: 'None',
            specs: {
              'options': ['None', 'Wave', 'Pulse', 'Sway', 'Fade']
            },
          ),
          DeviceProperty(
            identifier: 'animation_speed',
            name: 'Animation Speed',
            dataType: 'enum',
            value: 'Medium',
            specs: {
              'options': ['Slow', 'Medium', 'Fast']
            },
          ),
        ],
      ),
      'Thermostat': DeviceTSL(
        deviceType: 'Thermostat',
        properties: [
          DeviceProperty(
            identifier: 'power',
            name: 'Power',
            dataType: 'boolean',
            value: false,
          ),
          DeviceProperty(
            identifier: 'temperature',
            name: 'Temperature',
            dataType: 'float',
            value: 22.0,
            specs: {'min': 16.0, 'max': 30.0, 'step': 0.5, 'unit': 'C'},
          ),
          DeviceProperty(
            identifier: 'mode',
            name: 'Mode',
            dataType: 'enum',
            value: 'Heat',
            specs: {
              'options': ['Heat', 'Cool', 'Auto', 'Fan']
            },
          ),
          DeviceProperty(
            identifier: 'fan_speed',
            name: 'Fan Speed',
            dataType: 'enum',
            value: 'Auto',
            specs: {
              'options': ['Auto', 'Low', 'Medium', 'High']
            },
          ),
        ],
      ),
      'Camera': DeviceTSL(
        deviceType: 'Camera',
        properties: [
          DeviceProperty(
            identifier: 'power',
            name: 'Power',
            dataType: 'boolean',
            value: false,
          ),
          DeviceProperty(
            identifier: 'recording',
            name: 'Recording',
            dataType: 'boolean',
            value: false,
          ),
          DeviceProperty(
            identifier: 'motion_detection',
            name: 'Motion Detection',
            dataType: 'boolean',
            value: true,
          ),
          DeviceProperty(
            identifier: 'resolution',
            name: 'Resolution',
            dataType: 'enum',
            value: 'HD',
            specs: {
              'options': ['SD', 'HD', 'Full HD', '4K']
            },
          ),
        ],
      ),
    };
  }

  // Provide a default TSL for unknown device types
  DeviceTSL getDefaultTSL() {
    return DeviceTSL(
      deviceType: 'Unknown',
      properties: [
        DeviceProperty(
          identifier: 'power',
          name: 'Power',
          dataType: 'boolean',
          value: false,
        ),
      ],
    );
  }

  // Fetch TSL from backend API (implementation would depend on your API)
  Future<DeviceTSL> fetchTSLFromBackend(String deviceType) async {
    // This would be an API call in a real implementation
    // For now, we'll just return the predefined TSL with a delay to simulate network
    await Future.delayed(Duration(milliseconds: 300));
    return getTSLDefinitions()[deviceType] ?? getDefaultTSL();
  }
}
