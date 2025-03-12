// lib/presentation/devices/device_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_device_manager/config/theme.dart';
import 'package:smart_device_manager/data/models/device.dart';
import 'package:smart_device_manager/presentation/widgets/device_property_control.dart';
import 'package:smart_device_manager/presentation/scenarios/scenario_library_screen.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Device device;

  const DeviceDetailScreen({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  late Device _device;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _device = widget.device;

    // Load device property values from backend
    _loadDeviceProperties();
  }

  // Load the current property values from the backend
  Future<void> _loadDeviceProperties() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you'd fetch the latest device state from your backend
      // For now, we'll simulate a delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Set power to true if it's currently online
      if (_device.isOnline) {
        _device.setProperty('power', true, updateBackend: false);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading device: $e')),
      );
    }
  }

  // Handle property changes
  Future<void> _handlePropertyChange(String identifier, dynamic value) async {
    try {
      // Special handling for power property
      if (identifier == 'power') {
        // Update device online status
        _device.setStatus(value == true);
      }

      // Update the property value
      final success = await _device.setProperty(identifier, value);

      if (!success && mounted) {
        // Show error if update failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update device')),
        );
      }

      // Refresh UI
      setState(() {});
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_device.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsModal();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero section with device icon
                  _buildDeviceHeader(),

                  // Information section
                  _buildInfoSection(),

                  // Controls section - Only show if device is online
                  if (_device.isOnline) _buildControlsSection(),

                  // History section
                  _buildHistorySection(),
                ],
              ),
            ),
    );
  }

  // Build the device header with icon and basic controls
  Widget _buildDeviceHeader() {
    // Find the power property for the main toggle
    final hasPower = _device.tsl.properties.any((p) => p.identifier == 'power');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Device icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _device.iconData,
              size: 70,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Device name
          Text(
            _device.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Device type
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _device.type,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Power toggle (if available)
          if (hasPower)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Power',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: _device.getProperty('power') == true,
                  onChanged: (value) {
                    _handlePropertyChange('power', value);
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Build information section with device details
  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('ID', _device.id),
              _buildInfoRow('Type', _device.type),
              _buildInfoRow('Room', _device.room),
              _buildInfoRow('Status', _device.isOnline ? 'Online' : 'Offline'),
              // You could add more info rows here
            ],
          ),
        ),
      ),
    );
  }

  // Build controls section with dynamic TSL-based controls
  Widget _buildControlsSection() {
    // Get all properties except 'power' which is handled in the header
    final controlProperties =
        _device.tsl.properties.where((p) => p.identifier != 'power').toList();

    // If no properties to show, return empty container
    if (controlProperties.isEmpty) {
      return Container();
    }

    if (_device.type == 'Controller') {
      // First find the active scenario property
      final hasScenarioLibrary = _device.tsl.properties.any((p) =>
          p.identifier == 'active_scenario' &&
          p.specs?.containsKey('has_library') == true);

      if (hasScenarioLibrary) {
        // Get the current active scenario
        final activeScenario = _device.getProperty('active_scenario') ?? 'None';

// Format the display value to handle custom scenarios
        String displayScenario = activeScenario.toString();
        if (displayScenario.startsWith('Custom: ')) {
          // Extract just the name part for custom scenarios
          displayScenario =
              displayScenario.substring(8); // Remove 'Custom: ' prefix
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show the current scenario
            ListTile(
              leading: const Icon(Icons.theater_comedy),
              title: const Text('Active Scenario'),
              subtitle: Text(displayScenario),
              trailing: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ScenarioLibraryScreen(device: _device),
                    ),
                  );

                  // Refresh the page if we got a result back
                  if (result == true) {
                    setState(() {});
                  }
                },
                child: const Text('Browse Library'),
              ),
            ),

            const Divider(),

            // Show other controls as well
            // (you'd have to iterate through the remaining properties)
            ...controlProperties
                .where((p) => p.identifier != 'active_scenario')
                .map((property) => DevicePropertyControl(
                      device: _device,
                      property: property,
                      onPropertyChanged: _handlePropertyChange,
                    ))
                .toList(),
          ],
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Controls',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Generate controls dynamically based on TSL
              ...controlProperties
                  .map((property) => DevicePropertyControl(
                        device: _device,
                        property: property,
                        onPropertyChanged: _handlePropertyChange,
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  // Build history section
  Widget _buildHistorySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Activity History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildHistoryItem('Device turned on', '10:30 AM'),
              _buildHistoryItem('Settings updated', 'Yesterday'),
              _buildHistoryItem('Device connected', '2 days ago'),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build history items
  Widget _buildHistoryItem(String action, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Show settings modal
  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Device Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Rename Device'),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.room),
                title: const Text('Change Room'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle room change
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.update),
                title: const Text('Check for Updates'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle update check
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red[400]),
                title: Text(
                  'Remove Device',
                  style: TextStyle(color: Colors.red[400]),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show rename dialog
  void _showRenameDialog() {
    final TextEditingController controller =
        TextEditingController(text: _device.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Device'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter new device name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle device rename
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device renamed successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Show delete confirmation
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Device'),
          content: const Text(
              'Are you sure you want to remove this device? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Return to previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device removed successfully')),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
