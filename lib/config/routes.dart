// lib/config/routes.dart

import 'package:flutter/material.dart';
import 'package:smart_device_manager/data/models/device.dart'; // Add this import
import 'package:smart_device_manager/presentation/auth/login_screen.dart';
import 'package:smart_device_manager/presentation/auth/splash_screen.dart';
import 'package:smart_device_manager/presentation/devices/add_device_screen.dart';
import 'package:smart_device_manager/presentation/devices/device_detail_screen.dart';
import 'package:smart_device_manager/presentation/devices/device_list_screen.dart';
import 'package:smart_device_manager/presentation/home/home_screen.dart';

class AppRoutes {
  // Define named routes as constants for easy reference throughout the app
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String deviceList = '/devices';
  static const String deviceDetail = '/device-detail';
  static const String addDevice = '/add-device';

  // Route generator function that handles all navigation routing logic
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments if needed
    final args = settings.arguments;

    // Match route names to corresponding screens
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case deviceList:
        // For now, we'll create an empty list of devices
        // In a real app, you'd pass the actual devices list
        return MaterialPageRoute(
          builder: (_) => DeviceListScreen(devices: []),
        );

      case addDevice:
        return MaterialPageRoute(builder: (_) => const AddDeviceScreen());

      case deviceDetail:
        // Check if args is a Device
        if (args is Device) {
          return MaterialPageRoute(
            builder: (_) => DeviceDetailScreen(device: args),
          );
        }

        // Handle legacy code that might still pass a Map
        else if (args is Map<String, dynamic>) {
          // Convert the map to a Device object
          try {
            final device = _convertMapToDevice(args);
            return MaterialPageRoute(
              builder: (_) => DeviceDetailScreen(device: device),
            );
          } catch (e) {
            return _errorRoute('Invalid device data: $e');
          }
        }

        // Fallback for incorrect arguments
        return _errorRoute('Invalid device data');

      // If route not found
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  // Helper method to convert a Map to a Device object
  static Device _convertMapToDevice(Map<String, dynamic> map) {
    // Extract the required fields
    final id = map['id'] as String? ?? '';
    final name = map['name'] as String? ?? 'Unknown Device';
    final type = map['type'] as String? ?? 'Unknown';
    final room = map['room'] as String? ?? 'Unknown';
    final iconData = map['iconData'] as IconData? ?? Icons.device_unknown;
    final status = map['status'] as String? ?? 'offline';

    // Create and return a new Device
    return Device(
      id: id,
      name: name,
      type: type,
      room: room,
      iconData: iconData,
      status: status,
    );
  }

  // Helper method to create an error route
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Navigation helper methods for common routing operations
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(home);
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(login);
  }

  static void navigateToDeviceDetail(BuildContext context, Device device) {
    Navigator.of(context).pushNamed(deviceDetail, arguments: device);
  }

  static void navigateToAddDevice(BuildContext context) {
    Navigator.of(context).pushNamed(addDevice);
  }

  static void navigateToDeviceList(BuildContext context) {
    Navigator.of(context).pushNamed(deviceList);
  }
}
