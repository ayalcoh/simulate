// lib/presentation/devices/device_list_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_device_manager/config/theme.dart';
import 'package:smart_device_manager/data/models/device.dart';
import 'package:smart_device_manager/presentation/widgets/device_list_item.dart';

class DeviceListScreen extends StatefulWidget {
  final List<Device> devices;

  const DeviceListScreen({
    Key? key,
    required this.devices,
  }) : super(key: key);

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  // Filter options
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Online', 'Offline'];

  // Track searched text
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Handle device status changes
  void _handleDeviceStatusChanged(Device device, bool isOnline) {
    setState(() {
      // Find and update the device
      final index = widget.devices.indexWhere((d) => d.id == device.id);
      if (index >= 0) {
        widget.devices[index].setStatus(isOnline);
        // Also update power property if it exists
        if (widget.devices[index].tsl.properties
            .any((p) => p.identifier == 'power')) {
          widget.devices[index]
              .setProperty('power', isOnline, updateBackend: false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter devices based on selected filter and search query
    List<Device> filteredDevices = widget.devices;

    // Apply status filter
    if (_selectedFilter == 'Online') {
      filteredDevices =
          filteredDevices.where((device) => device.isOnline).toList();
    } else if (_selectedFilter == 'Offline') {
      filteredDevices =
          filteredDevices.where((device) => !device.isOnline).toList();
    }

    // Apply search filter if there's a search query
    if (_searchQuery.isNotEmpty) {
      filteredDevices = filteredDevices.where((device) {
        final query = _searchQuery.toLowerCase();
        return device.name.toLowerCase().contains(query) ||
            device.type.toLowerCase().contains(query) ||
            device.room.toLowerCase().contains(query);
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Devices'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar (if search is active)
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search: $_searchQuery',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),

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
                      return DeviceListItem(
                        device: filteredDevices[index],
                        onDeviceStatusChanged: _handleDeviceStatusChanged,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Show search dialog
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Devices'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Enter device name, type, or room',
              prefixIcon: Icon(Icons.search),
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
                setState(() {
                  _searchQuery = _searchController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}
