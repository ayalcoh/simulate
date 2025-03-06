// lib/presentation/devices/device_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_device_manager/config/theme.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> device;

  const DeviceDetailScreen({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  bool _isDeviceOn = false;
  double _sliderValue = 50;

  @override
  void initState() {
    super.initState();
    _isDeviceOn = widget.device['status'] == 'online';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device['name']),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section with device icon
            Container(
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
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.device['iconData'],
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.device['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      widget.device['type'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                        value: _isDeviceOn,
                        onChanged: (value) {
                          setState(() {
                            _isDeviceOn = value;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.white.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Information section
            Padding(
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
                      _buildInfoRow('ID', widget.device['id']),
                      _buildInfoRow('Type', widget.device['type']),
                      _buildInfoRow('Room', widget.device['room']),
                      _buildInfoRow(
                          'Status', _isDeviceOn ? 'Online' : 'Offline'),
                    ],
                  ),
                ),
              ),
            ),

            // Controls section
            if (_isDeviceOn)
              Padding(
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
                        if (widget.device['type'] == 'Light')
                          _buildLightControls()
                        else if (widget.device['type'] == 'Thermostat')
                          _buildThermostatControls()
                        else if (widget.device['type'] == 'Camera')
                          _buildCameraControls()
                        else
                          _buildGenericControls(),
                      ],
                    ),
                  ),
                ),
              ),

            // History section
            Padding(
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
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildLightControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brightness control
        Row(
          children: [
            const Icon(Icons.brightness_6, color: Colors.amber),
            const SizedBox(width: 12),
            const Text('Brightness'),
            Expanded(
              child: Slider(
                value: _sliderValue,
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
                min: 0,
                max: 100,
                divisions: 10,
                label: '${_sliderValue.round()}%',
                activeColor: AppTheme.primaryColor,
              ),
            ),
            Text('${_sliderValue.round()}%'),
          ],
        ),
        // Color temperature
        Row(
          children: [
            const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
            const SizedBox(width: 12),
            const Text('Color Temperature'),
            Expanded(
              child: Slider(
                value: 70,
                onChanged: (value) {
                  // Handle color temperature change
                },
                min: 0,
                max: 100,
                divisions: 10,
                activeColor: Colors.orange,
              ),
            ),
            const Text('Warm'),
          ],
        ),
      ],
    );
  }

  Widget _buildThermostatControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Temperature display
        Center(
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_sliderValue.round()}°',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Text(
                  'Celsius',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Temperature slider
        Row(
          children: [
            const Icon(Icons.ac_unit, color: Colors.blue),
            Expanded(
              child: Slider(
                value: _sliderValue,
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
                min: 16,
                max: 30,
                divisions: 14,
                activeColor: AppTheme.primaryColor,
              ),
            ),
            const Icon(Icons.whatshot, color: Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildCameraControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Camera preview (mock)
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.videocam,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Camera controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(Icons.photo_camera, 'Capture'),
            _buildControlButton(Icons.videocam, 'Record'),
            _buildControlButton(Icons.mic, 'Talk'),
            _buildControlButton(Icons.fullscreen, 'Fullscreen'),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: AppTheme.primaryColor),
            onPressed: () {
              // Handle control action
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildGenericControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.speed, color: AppTheme.primaryColor),
          title: const Text('Mode'),
          trailing: DropdownButton<String>(
            value: 'Normal',
            onChanged: (String? newValue) {
              // Handle mode change
            },
            items: <String>['Normal', 'Eco', 'Boost', 'Auto']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            underline: Container(
              height: 0,
            ),
          ),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.timer, color: AppTheme.primaryColor),
          title: const Text('Schedule'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to schedule screen
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.notifications, color: AppTheme.primaryColor),
          title: const Text('Notifications'),
          trailing: Switch(
            value: true,
            onChanged: (value) {
              // Handle notifications toggle
            },
            activeColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

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

  void _showRenameDialog() {
    final TextEditingController controller =
        TextEditingController(text: widget.device['name']);

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
