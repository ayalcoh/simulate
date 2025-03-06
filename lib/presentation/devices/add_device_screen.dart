// lib/presentation/devices/add_device_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_device_manager/config/theme.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({Key? key}) : super(key: key);

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  // Track the current step in the setup process
  int _currentStep = 0;

  // Mock data for found devices
  List<Map<String, dynamic>> _foundDevices = [];
  bool _isScanning = false;

  // Selected device
  Map<String, dynamic>? _selectedDevice;

  // Room selection for the device
  String _selectedRoom = 'Living Room';
  final List<String> _roomOptions = [
    'Living Room',
    'Bedroom',
    'Kitchen',
    'Bathroom',
    'Office',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Device'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: Colors.grey[200],
            color: AppTheme.primaryColor,
          ),

          // Step title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 14,
                  child: Text(
                    '${_currentStep + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getStepTitle(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Step content
          Expanded(
            child: _buildStepContent(),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Back'),
                  )
                else
                  const SizedBox(width: 80),
                ElevatedButton(
                  onPressed: _handleNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_currentStep == 2 ? 'Finish' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Get the title for the current step
  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Select Connection Method';
      case 1:
        return 'Choose Device';
      case 2:
        return 'Configure Device';
      default:
        return '';
    }
  }

  // Build content based on current step
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildConnectionMethodStep();
      case 1:
        return _buildDeviceSelectionStep();
      case 2:
        return _buildDeviceConfigurationStep();
      default:
        return Container();
    }
  }

  // Step 1: Select connection method
  Widget _buildConnectionMethodStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'How would you like to connect your device?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // WiFi option
          _buildConnectionOption(
            icon: Icons.wifi,
            title: 'WiFi',
            description: 'Connect devices on your WiFi network',
            isSelected: true,
          ),

          const SizedBox(height: 16),

          // Bluetooth option
          _buildConnectionOption(
            icon: Icons.bluetooth,
            title: 'Bluetooth',
            description: 'Connect devices via Bluetooth',
            isSelected: false,
          ),

          const SizedBox(height: 16),

          // Direct connect option
          _buildConnectionOption(
            icon: Icons.link,
            title: 'Direct Connect',
            description: 'Connect devices by entering ID manually',
            isSelected: false,
          ),
        ],
      ),
    );
  }

  // Step 2: Select device from found devices
  Widget _buildDeviceSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Searching for devices on your network...',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Scanning animation
          if (_isScanning)
            Column(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Scanning...'),
              ],
            )
          else if (_foundDevices.isEmpty)
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _startScan,
                  icon: const Icon(Icons.search),
                  label: const Text('Start Scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'No devices found yet. Make sure your device is in pairing mode.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Found ${_foundDevices.length} devices',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _foundDevices.length,
                      itemBuilder: (context, index) {
                        final device = _foundDevices[index];
                        final bool isSelected = _selectedDevice == device;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDevice = device;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    device['iconData'],
                                    color: AppTheme.primaryColor,
                                    size: 36,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          device['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          device['type'],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Radio<Map<String, dynamic>>(
                                    value: device,
                                    groupValue: _selectedDevice,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDevice = value;
                                      });
                                    },
                                    activeColor: AppTheme.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          if (_foundDevices.isNotEmpty && !_isScanning)
            TextButton.icon(
              onPressed: _startScan,
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Again'),
            ),
        ],
      ),
    );
  }

  // Step 3: Configure the selected device
  Widget _buildDeviceConfigurationStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device info
          Center(
            child: Column(
              children: [
                Icon(
                  _selectedDevice?['iconData'] ?? Icons.device_unknown,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedDevice?['name'] ?? 'Unknown Device',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _selectedDevice?['type'] ?? 'Device',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Device name
          const Text(
            'Device Name',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter device name',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.edit),
            ),
            controller: TextEditingController(text: _selectedDevice?['name']),
          ),

          const SizedBox(height: 24),

          // Room selection
          const Text(
            'Room',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRoom,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedRoom = newValue;
                    });
                  }
                },
                items:
                    _roomOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Auto-connect option
          SwitchListTile(
            title: const Text('Auto-Connect'),
            subtitle: const Text('Automatically connect when in range'),
            value: true,
            onChanged: (value) {
              // Handle auto-connect toggle
            },
            activeColor: AppTheme.primaryColor,
            contentPadding: EdgeInsets.zero,
          ),

          const Divider(),

          // Notifications option
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Receive notifications from this device'),
            value: true,
            onChanged: (value) {
              // Handle notifications toggle
            },
            activeColor: AppTheme.primaryColor,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // Helper to build connection method options
  Widget _buildConnectionOption({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
  }) {
    return Card(
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (value) {
                // Handle selection change
              },
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  // Handle the next step button
  void _handleNextStep() {
    if (_currentStep == 0) {
      setState(() {
        _currentStep++;
        _startScan(); // Start scanning for devices when entering step 2
      });
    } else if (_currentStep == 1) {
      if (_selectedDevice != null) {
        setState(() {
          _currentStep++;
        });
      } else {
        // Show error if no device selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a device to continue')),
        );
      }
    } else if (_currentStep == 2) {
      // Finish the process
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device added successfully')),
      );
    }
  }

  // Start the device scanning process
  void _startScan() {
    setState(() {
      _isScanning = true;
      _foundDevices = [];
      _selectedDevice = null;
    });

    // Simulate device scanning with a delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isScanning = false;
        // Mock found devices
        _foundDevices = [
          {
            'id': 'YM-T5',
            'name': 'YM-T5',
            'type': 'Controller',
            'iconData': Icons.device_hub,
          },
          {
            'id': 'YM-S3',
            'name': 'YM-S3',
            'type': 'Sensor',
            'iconData': Icons.sensors,
          },
          {
            'id': 'YM-L2',
            'name': 'YM-L2',
            'type': 'Light',
            'iconData': Icons.lightbulb_outline,
          },
        ];
      });
    });
  }
}
