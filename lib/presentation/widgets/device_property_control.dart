// lib/presentation/widgets/device_property_control.dart

import 'package:flutter/material.dart';
import 'package:smart_device_manager/config/theme.dart';
import 'package:smart_device_manager/data/models/device.dart';
import 'package:smart_device_manager/data/models/device_property.dart';

class DevicePropertyControl extends StatefulWidget {
  final Device device;
  final DeviceProperty property;
  final Function(String, dynamic) onPropertyChanged;

  const DevicePropertyControl({
    Key? key,
    required this.device,
    required this.property,
    required this.onPropertyChanged,
  }) : super(key: key);

  @override
  State<DevicePropertyControl> createState() => _DevicePropertyControlState();
}

class _DevicePropertyControlState extends State<DevicePropertyControl> {
  // Track if a property update is in progress
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    // Get the current value of the property
    final value = widget.device.getProperty(widget.property.identifier);

    // Render different controls based on the property data type
    switch (widget.property.dataType) {
      case 'boolean':
        return _buildBooleanControl(value);
      case 'integer':
      case 'float':
        return _buildNumericControl(value);
      case 'enum':
        return _buildEnumControl(value);
      case 'string':
        return _buildStringControl(value);
      default:
        return _buildDefaultControl(value);
    }
  }

  // Boolean toggle control (for on/off, enabled/disabled, etc.)
  Widget _buildBooleanControl(dynamic value) {
    // Create a safe boolean value
    bool boolValue = value == true;

    return SwitchListTile(
      title: Text(widget.property.name),
      value: boolValue,
      activeColor: AppTheme.primaryColor,
      onChanged: _isUpdating
          ? null
          : (newValue) async {
              setState(() {
                _isUpdating = true;
              });

              await widget.onPropertyChanged(
                  widget.property.identifier, newValue);

              setState(() {
                _isUpdating = false;
              });
            },
    );
  }

  // Numeric slider control (for brightness, temperature, etc.)
  Widget _buildNumericControl(dynamic value) {
    // Get specs or set defaults
    final specs = widget.property.specs ?? {};
    final min = (specs['min'] as num?)?.toDouble() ?? 0.0;
    final max = (specs['max'] as num?)?.toDouble() ?? 100.0;
    final step = (specs['step'] as num?)?.toDouble() ?? 1.0;
    final unit = specs['unit'] as String? ?? '';

    // Ensure value is within range
    double numValue = (value as num?)?.toDouble() ?? min;
    if (numValue < min) numValue = min;
    if (numValue > max) numValue = max;

    // Calculate divisions for the slider
    final divisions = ((max - min) / step).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property name and current value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.property.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              _isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      '${numValue.toStringAsFixed(step < 1 ? 1 : 0)}$unit',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 8),

          // Slider control
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.2),
              thumbColor: AppTheme.accentColor,
              overlayColor: AppTheme.primaryColor.withOpacity(0.1),
              valueIndicatorColor: AppTheme.primaryColor,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
              ),
            ),
            child: Slider(
              value: numValue,
              min: min,
              max: max,
              divisions: divisions,
              label: '${numValue.toStringAsFixed(step < 1 ? 1 : 0)}$unit',
              onChanged: _isUpdating
                  ? null
                  : (newValue) {
                      // Update UI immediately for responsiveness
                      setState(() {});
                    },
              onChangeEnd: _isUpdating
                  ? null
                  : (newValue) async {
                      setState(() {
                        _isUpdating = true;
                      });

                      // Convert to int if the property type is integer
                      final finalValue = widget.property.dataType == 'integer'
                          ? newValue.round()
                          : newValue;

                      await widget.onPropertyChanged(
                          widget.property.identifier, finalValue);

                      setState(() {
                        _isUpdating = false;
                      });
                    },
            ),
          ),

          // Min/Max labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                min.toStringAsFixed(step < 1 ? 1 : 0),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                max.toStringAsFixed(step < 1 ? 1 : 0),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnumControl(dynamic value) {
    // Get options from specs or provide a fallback
    final specs = widget.property.specs ?? {};
    final options = specs['options'] as List<dynamic>? ?? ['Default'];

    // Ensure the current value is in options
    String stringValue = (value as String?) ?? options.first.toString();

    // Add handling for custom scenarios
    String displayValue = stringValue;
    bool isCustomScenario = false;

    // Check if this is the active_scenario property and has a custom value
    if (widget.property.identifier == 'active_scenario' &&
        stringValue.startsWith('Custom: ')) {
      // This is a custom scenario
      displayValue = stringValue.substring(8); // Remove 'Custom: ' prefix
      isCustomScenario = true;
    }

    // For standard enum values, ensure they exist in the options list
    if (!isCustomScenario && !options.contains(stringValue)) {
      stringValue = options.first.toString();
      displayValue = stringValue;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.property.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          _isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isCustomScenario
                      // For custom scenarios, show text instead of dropdown
                      ? Text(
                          displayValue,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      // For standard enum values, show dropdown
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: stringValue,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.primaryColor,
                            ),
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            items: options
                                .map<DropdownMenuItem<String>>((dynamic value) {
                              return DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: _isUpdating
                                ? null
                                : (newValue) async {
                                    if (newValue == null) return;

                                    setState(() {
                                      _isUpdating = true;
                                    });

                                    await widget.onPropertyChanged(
                                        widget.property.identifier, newValue);

                                    setState(() {
                                      _isUpdating = false;
                                    });
                                  },
                          ),
                        ),
                ),
        ],
      ),
    );
  }

  // String input control (for names, textual input, etc.)
  Widget _buildStringControl(dynamic value) {
    // Create a controller for the text field
    final controller = TextEditingController(text: value?.toString() ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.property.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: _isUpdating
                      ? null
                      : (newValue) async {
                          setState(() {
                            _isUpdating = true;
                          });

                          await widget.onPropertyChanged(
                              widget.property.identifier, newValue);

                          setState(() {
                            _isUpdating = false;
                          });
                        },
                ),
              ),
              if (_isUpdating)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Default control for any other property types
  Widget _buildDefaultControl(dynamic value) {
    return ListTile(
      title: Text(widget.property.name),
      subtitle: Text(value?.toString() ?? 'Not set'),
    );
  }
}
