// lib/presentation/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_device_manager/config/theme.dart';
import 'package:smart_device_manager/presentation/devices/add_device_screen.dart';
import 'package:smart_device_manager/presentation/devices/device_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track which tab is currently selected in the bottom navigation
  int _currentIndex = 0;

  // Mock data for connected devices - in a real app, this would come from your repository
  final List<Map<String, dynamic>> _connectedDevices = [
    {
      'id': '1',
      'name': 'YM-T2',
      'type': 'controller',
      'status': 'online',
      'iconData': Icons.device_hub,
    },
    {
      'id': '2',
      'name': 'YM-S1',
      'type': 'sensor',
      'status': 'online',
      'iconData': Icons.sensors,
    },
    {
      'id': '3',
      'name': 'YM-L1',
      'type': 'light',
      'status': 'offline',
      'iconData': Icons.lightbulb_outline,
    },
  ];

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
            label: 'Home', // Home
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Devices', // Devices
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover', // Discover
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile', // Profile
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
        return const DeviceListScreen(); // We'll create this screen next
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
      child: Column(
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
                      '我的设备', // My Devices
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
                      '${_connectedDevices.length} X devices connected', // X devices connected
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
                      label: const Text('Add Device'), // Add Device
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
                  'Device Categories', // Device Categories
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
                    _buildCategoryItem(Icons.all_inclusive, 'All'), // All
                    _buildCategoryItem(Icons.tv, 'Living Room'), // Living Room
                    _buildCategoryItem(Icons.king_bed, 'Bedroom'), // Bedroom
                    _buildCategoryItem(Icons.kitchen, 'Kitchen'), // Kitchen
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
                    'Recently Connected', // Recently Connected
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Scrollable list of device items
                  Expanded(
                    child: ListView.builder(
                      itemCount: _connectedDevices.length,
                      itemBuilder: (context, index) {
                        final device = _connectedDevices[index];
                        return _buildDeviceItem(device);
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

  // Helper method to build each device item in the list
  Widget _buildDeviceItem(Map<String, dynamic> device) {
    final bool isOnline = device['status'] == 'online';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isOnline
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            device['iconData'],
            color: isOnline ? AppTheme.primaryColor : Colors.grey,
          ),
        ),
        title: Text(
          device['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(device['type']),
        trailing: Switch(
          value: isOnline,
          onChanged: (value) {
            // In a real app, this would connect/disconnect the device
            setState(() {
              _connectedDevices[_connectedDevices.indexOf(device)]['status'] =
                  value ? 'online' : 'offline';
            });
          },
          activeColor: AppTheme.primaryColor,
        ),
        onTap: () {
          // Navigate to device detail page (we'll implement this later)
        },
      ),
    );
  }

  // Placeholder for Discover tab - will implement later
  Widget _buildDiscoverPage() {
    return const Center(
      child: Text(
          'Discover page - to be implemented'), // Discover page - to be implemented
    );
  }

  // Placeholder for Profile tab - will implement later
  Widget _buildProfilePage() {
    return const Center(
      child: Text(
          'Profile page - to be implemnted'), // Profile page - to be implemented
    );
  }
}
