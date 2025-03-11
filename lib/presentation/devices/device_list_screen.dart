// lib/presentation/devices/device_list_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_device_manager/config/theme.dart';
import 'package:smart_device_manager/presentation/devices/device_detail_screen.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  // Mock data for connected devices - in a real app, this would come from your repository
  final List<Map<String, dynamic>> _devices = [
    {
      'id': '1',
      'name': 'LightBox-1',
      'type': 'Controller',
      'status': 'online',
      'room': 'Living Room',
      'iconData': Icons.device_hub,
    },
    {
      'id': '2',
      'name': 'Sensor-1',
      'type': 'Sensor',
      'status': 'online',
      'room': 'Bedroom',
      'iconData': Icons.sensors,
    },
    {
      'id': '3',
      'name': 'LED-1',
      'type': 'Light',
      'status': 'offline',
      'room': 'Kitchen',
      'iconData': Icons.lightbulb_outline,
    },
    {
      'id': '4',
      'name': 'Thermostat-1',
      'type': 'Thermostat',
      'status': 'online',
      'room': 'Living Room',
      'iconData': Icons.thermostat,
    },
    {
      'id': '5',
      'name': 'Camera-1',
      'type': 'Camera',
      'status': 'offline',
      'room': 'Front Door',
      'iconData': Icons.videocam,
    },
  ];

  // Filter options
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Online', 'Offline'];

  @override
  Widget build(BuildContext context) {
    // Filter devices based on selected filter
    List<Map<String, dynamic>> filteredDevices = _devices;
    if (_selectedFilter == 'Online') {
      filteredDevices =
          _devices.where((device) => device['status'] == 'online').toList();
    } else if (_selectedFilter == 'Offline') {
      filteredDevices =
          _devices.where((device) => device['status'] == 'offline').toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Devices'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Filter: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filterOptions.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor:
                                AppTheme.primaryColor.withOpacity(0.2),
                            checkmarkColor: AppTheme.primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Device count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '${filteredDevices.length} devices',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Device list
          Expanded(
            child: filteredDevices.isEmpty
                ? const Center(
                    child: Text('No devices found'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDevices.length,
                    itemBuilder: (context, index) {
                      final device = filteredDevices[index];
                      return _buildDeviceCard(device);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final bool isOnline = device['status'] == 'online';

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
          child: Row(
            children: [
              // Device icon
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
                  device['iconData'],
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
                          device['name'],
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
                      device['type'],
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
                          device['room'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Toggle switch
              Switch(
                value: isOnline,
                onChanged: (value) {
                  // In a real app, this would connect/disconnect the device
                  setState(() {
                    _devices[
                            _devices.indexWhere((d) => d['id'] == device['id'])]
                        ['status'] = value ? 'online' : 'offline';
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
