// lib/presentation/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_device_manager/config/theme.dart';
import 'package:smart_device_manager/data/models/device.dart';
import 'package:smart_device_manager/presentation/devices/add_device_screen.dart';
import 'package:smart_device_manager/presentation/devices/device_list_screen.dart';
import 'package:smart_device_manager/presentation/widgets/device_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track which tab is currently selected in the bottom navigation
  int _currentIndex = 0;

  // Track if data is loading
  bool _isLoading = true;

  // List of devices
  List<Device> _devices = [];

  @override
  void initState() {
    super.initState();
    // Load devices
    _loadDevices();
  }

  // Load devices from backend (simulated)
  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you'd fetch this from your backend
      _devices = [
        Device(
          id: '1',
          name: 'LightBox-1',
          type: 'Controller',
          room: 'Living Room',
          iconData: Icons.device_hub,
          status: 'online',
        ),
        Device(
          id: '2',
          name: 'Sensor-1',
          type: 'Sensor',
          room: 'Bedroom',
          iconData: Icons.sensors,
          status: 'online',
        ),
        Device(
          id: '3',
          name: 'LED-1',
          type: 'Light',
          room: 'Kitchen',
          iconData: Icons.lightbulb_outline,
          status: 'offline',
        ),
      ];

      // Set initial property values (in a real app, these would come from the backend)
      _devices[0].setProperty('power', true, updateBackend: false);
      _devices[0].setProperty('mode', 'Standard', updateBackend: false);

      _devices[1].setProperty('active', true, updateBackend: false);
      _devices[1].setProperty('reading', 23.5, updateBackend: false);

      _devices[2].setProperty('power', false, updateBackend: false);
      _devices[2].setProperty('brightness', 80, updateBackend: false);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading devices: $e')),
      );
    }
  }

  // Handle device status changes
  void _handleDeviceStatusChanged(Device device, bool isOnline) {
    setState(() {
      // Find and update the device
      final index = _devices.indexWhere((d) => d.id == device.id);
      if (index >= 0) {
        _devices[index].setStatus(isOnline);
        // Also update power property if it exists
        if (_devices[index]
            .tsl
            .properties
            .any((p) => p.identifier == 'power')) {
          _devices[index].setProperty('power', isOnline, updateBackend: false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body will change based on which tab is selected
      body: _buildCurrentPage(),

      // Bottom navigation bar for main app sections
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Keeps all icons visible
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Devices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Helper method to determine which page to show based on selected tab
  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return DeviceListScreen(devices: _devices);
      case 2:
        return _buildDiscoverPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
  }

  // Main home page content
  Widget _buildHomePage() {
    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with gradient background
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row with title and notification icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Devices',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: IconButton(
                              icon: const Icon(Icons.notifications,
                                  color: Colors.white),
                              onPressed: () {
                                // Handle notifications
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Device count and add device button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_devices.length} devices connected',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AddDeviceScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Device'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Device categories section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Device Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Row of category icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCategoryItem(Icons.all_inclusive, 'All'),
                          _buildCategoryItem(Icons.tv, 'Living Room'),
                          _buildCategoryItem(Icons.king_bed, 'Bedroom'),
                          _buildCategoryItem(Icons.kitchen, 'Kitchen'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Recently connected devices list
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recently Connected',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Scrollable list of device items
                        Expanded(
                          child: ListView.builder(
                            itemCount: _devices.length,
                            itemBuilder: (context, index) {
                              return DeviceListItem(
                                device: _devices[index],
                                onDeviceStatusChanged:
                                    _handleDeviceStatusChanged,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Helper method to build a category icon item
  Widget _buildCategoryItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Placeholder for Discover tab - will implement later
  Widget _buildDiscoverPage() {
    return const Center(
      child: Text('Discover page - to be implemented'),
    );
  }

  // Placeholder for Profile tab - will implement later
  Widget _buildProfilePage() {
    return const Center(
      child: Text('Profile page - to be implemented'),
    );
  }
}
