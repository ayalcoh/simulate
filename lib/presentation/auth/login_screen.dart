// lib/presentation/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:smart_device_manager/config/theme.dart';
import 'package:smart_device_manager/presentation/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers to handle user input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Local authentication plugin for biometric auth
  final LocalAuthentication _localAuth = LocalAuthentication();

  // State to track which login method is active
  bool _isPasswordLogin = true;

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method to handle biometric authentication
  Future<void> _authenticateWithBiometrics() async {
    try {
      // Check if device supports biometric authentication
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (canAuthenticate) {
        // Attempt authentication
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to access your devices',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        // Navigate to home screen if authentication is successful
        if (didAuthenticate) {
          if (mounted) {
            // Check if widget is still mounted before using context
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }
      } else {
        // Show message if biometric authentication is not available
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Biometric authentication not available')),
          );
          // Fall back to password login
          setState(() {
            _isPasswordLogin = true;
          });
        }
      }
    } catch (e) {
      print('Error during biometric authentication: $e');
      // Handle authentication errors
    }
  }

  // Method to handle password login
  void _login() {
    // This is a simple validation for demonstration purposes
    // In a real app, you'd validate against a backend service
    if (_passwordController.text.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Apply gradient to top portion of screen
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top section with gradient background
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome to Lucezzo', // "Welcome to [app name]"
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom section with white background
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Login type selection tabs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildLoginTypeButton(
                              'Password login', // "Password login"
                              true,
                              Icons.lock_outline,
                            ),
                            _buildLoginTypeButton(
                              'Biometric login', // "Biometric login"
                              false,
                              Icons.fingerprint,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Show either password form or biometric login UI
                        _isPasswordLogin
                            ? _buildPasswordLogin()
                            : _buildBiometricLogin(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the login type selection buttons
  Widget _buildLoginTypeButton(String title, bool isPassword, IconData icon) {
    final isSelected = _isPasswordLogin == isPassword;

    return InkWell(
      onTap: () {
        setState(() {
          _isPasswordLogin = isPassword;
        });
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primaryColor : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          // Indicator line to show which tab is selected
          Container(
            height: 3,
            width: 80,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // Password login form UI
  Widget _buildPasswordLogin() {
    return Column(
      children: [
        // Username/Phone field
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Phone/Username', // Phone/Username
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Password field
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  obscureText: true, // Hide password text
                  decoration: const InputDecoration(
                    hintText: 'Password', // Password
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Login button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _login,
            child: const Text(
              'Login', // Login
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  // Biometric login UI
  Widget _buildBiometricLogin() {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Icon(
          Icons.fingerprint,
          size: 100,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 32),
        const Text(
          'Tap fingerprint sensor', // "Tap fingerprint sensor"
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _authenticateWithBiometrics,
            child: const Text(
              'Login with biometrics', // "Login with biometrics"
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
