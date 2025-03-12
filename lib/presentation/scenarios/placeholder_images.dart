// lib/presentation/scenarios/placeholder_images.dart

import 'package:flutter/material.dart';

// This class provides placeholder images for scenarios
// Replace these with real images when available
class PlaceholderScenarioImage extends StatelessWidget {
  final String scenarioId;
  final Color color;

  const PlaceholderScenarioImage({
    Key? key,
    required this.scenarioId,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Icon(
          _getIconForScenario(scenarioId),
          color: Colors.white.withOpacity(0.7),
          size: 64,
        ),
      ),
    );
  }

  IconData _getIconForScenario(String id) {
    switch (id) {
      case 'ocean':
        return Icons.water;
      case 'forest':
        return Icons.forest;
      case 'sunshine':
        return Icons.wb_sunny;
      case 'evening':
        return Icons.nights_stay;
      case 'party':
        return Icons.celebration;
      default:
        return Icons.lightbulb;
    }
  }
}
