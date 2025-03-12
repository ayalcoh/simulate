// lib/presentation/widgets/device_list_item.dart

import 'package:flutter/material.dart';
import 'package:smart_device_manager/config/theme.dart';
import 'package:smart_device_manager/data/models/device.dart';
import 'package:smart_device_manager/presentation/devices/device_detail_screen.dart';

class DeviceListItem extends StatefulWidget {
  final Device device;
  final Function(Device, bool) onDeviceStatusChanged;

  const DeviceListItem({
    Key? key,
    required this.device,
    required this.onDeviceStatusChanged,
  }) : super(key: key);

  @override
  State<DeviceListItem> createState() => _DeviceListItemState();
}

class _DeviceListItemState extends State<DeviceListItem> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final bool isOnline = device.isOnline;

    // Check if this device has a primary quick action property
    final hasPower = device.tsl.properties.any((p) => p.identifier == 'power');
    final hasBrightness =
        device.tsl.properties.any((p) => p.identifier == 'brightness');
    final hasTemperature =
        device.tsl.properties.any((p) => p.identifier == 'temperature');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceDetailScreen(device: device),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // lib/presentation/widgets/device_list_item.dart (continued)
          child: Row(
            children: [
              // Device icon with status-based styling
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  device.iconData,
                  color: isOnline ? AppTheme.primaryColor : Colors.grey,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              // Device info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isOnline ? Colors.green[50] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              color: isOnline ? Colors.green : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.type,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.room,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          device.room,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    // Show key property info based on device type
                    if (isOnline && (hasBrightness || hasTemperature))
                      _buildQuickInfoChip(device),
                  ],
                ),
              ),

              // Show appropriate quick control based on device type
              _isUpdating
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor),
                      ),
                    )
                  : _buildQuickControl(
                      device, hasPower, hasBrightness, hasTemperature),
            ],
          ),
        ),
      ),
    );
  }

  // Build a quick info chip to show a key property value
  Widget _buildQuickInfoChip(Device device) {
    // Check for common properties to display based on device type
    if (device.tsl.properties.any((p) => p.identifier == 'brightness')) {
      final brightness = device.getProperty('brightness');
      if (brightness != null) {
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Brightness: ${brightness.toString()}%',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
    } else if (device.tsl.properties
        .any((p) => p.identifier == 'temperature')) {
      final temperature = device.getProperty('temperature');
      if (temperature != null) {
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${temperature.toString()}°C',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
    }

    return Container(); // Return empty if no relevant property
  }

  // Build a quick control based on device type
  Widget _buildQuickControl(
      Device device, bool hasPower, bool hasBrightness, bool hasTemperature) {
    // If device has power, show power toggle
    if (hasPower) {
      return Switch(
        value: device.getProperty('power') == true,
        onChanged: (value) async {
          setState(() {
            _isUpdating = true;
          });

          // Update the power state
          await device.setProperty('power', value);

          // Update the online status
          widget.onDeviceStatusChanged(device, value);

          setState(() {
            _isUpdating = false;
          });
        },
        activeColor: AppTheme.primaryColor,
      );
    }

    // For future extensibility, you could add quick controls for brightness, temperature, etc.

    // Default to a chevron icon to indicate device can be opened
    return Icon(
      Icons.chevron_right,
      color: Colors.grey[400],
    );
  }
}
