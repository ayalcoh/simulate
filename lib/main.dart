// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_device_manager/config/routes.dart';
import 'package:smart_device_manager/config/theme.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title displayed in recent apps
      title: 'Lucezzo',

      // Apply the app theme
      theme: AppTheme.lightTheme,

      // Configure routing
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,

      // Remove debug banner
      debugShowCheckedModeBanner: false,

      // Localization settings (can be expanded later)
      locale: const Locale('en', 'US'),

      // Error handling for the entire app
      builder: (context, child) {
        // Add error boundary widget if needed
        return MediaQuery(
          // Handle text scaling for accessibility
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
