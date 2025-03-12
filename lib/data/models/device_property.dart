// lib/data/models/device_property.dart

class DeviceProperty {
  final String identifier; // Unique identifier for the property
  final String name; // Display name
  final String dataType; // 'boolean', 'integer', 'float', 'enum', etc.
  final dynamic value; // Default value
  final Map<String, dynamic>?
      specs; // Additional specifications like min/max/options

  DeviceProperty({
    required this.identifier,
    required this.name,
    required this.dataType,
    this.value,
    this.specs,
  });

  // Create from JSON (useful when receiving from API)
  factory DeviceProperty.fromJson(Map<String, dynamic> json) {
    return DeviceProperty(
      identifier: json['identifier'],
      name: json['name'],
      dataType: json['dataType'],
      value: json['value'],
      specs: json['specs'],
    );
  }

  // Convert to JSON (useful when sending to API)
  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'name': name,
      'dataType': dataType,
      'value': value,
      'specs': specs,
    };
  }
}
