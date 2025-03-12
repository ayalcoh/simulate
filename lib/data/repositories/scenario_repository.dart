// lib/data/repositories/scenario_repository.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_device_manager/data/models/scenario.dart';

class ScenarioRepository {
  static const String _userScenariosKey = 'user_scenarios';

  // Get built-in scenarios
  List<Scenario> getBuiltInScenarios() {
    return [
      Scenario(
        id: 'ocean',
        name: 'Ocean',
        description: 'Calm blue waves and gentle sounds',
        imageUrl: 'assets/images/scenarios/ocean.jpg',
        settings: {
          'color': '#0077be',
          'brightness': 60,
          'animation': 'Wave',
          'animation_speed': 'Slow',
        },
      ),
      Scenario(
        id: 'forest',
        name: 'Forest',
        description: 'Lush green forest atmosphere',
        imageUrl: 'assets/images/scenarios/forest.jpg',
        settings: {
          'color': '#228b22',
          'brightness': 70,
          'animation': 'Sway',
          'animation_speed': 'Medium',
        },
      ),
      Scenario(
        id: 'sunshine',
        name: 'Sunshine',
        description: 'Bright and energizing sunshine',
        imageUrl: 'assets/images/scenarios/sunshine.jpg',
        settings: {
          'color': '#ffd700',
          'brightness': 90,
          'animation': 'Pulse',
          'animation_speed': 'Fast',
        },
      ),
      Scenario(
        id: 'evening',
        name: 'Evening',
        description: 'Warm and cozy evening ambiance',
        imageUrl: 'assets/images/scenarios/evening.jpg',
        settings: {
          'color': '#ff7f50',
          'brightness': 40,
          'animation': 'Fade',
          'animation_speed': 'Slow',
        },
      ),
      Scenario(
        id: 'party',
        name: 'Party',
        description: 'Vibrant and dynamic party mode',
        imageUrl: 'assets/images/scenarios/party.jpg',
        settings: {
          'color': '#9932cc',
          'brightness': 85,
          'animation': 'Pulse',
          'animation_speed': 'Fast',
        },
      ),
    ];
  }

  // Get user-created scenarios
  Future<List<Scenario>> getUserScenarios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scenariosJson = prefs.getString(_userScenariosKey);

      if (scenariosJson == null) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(scenariosJson);
      return decoded.map((item) => Scenario.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading user scenarios: $e');
      return [];
    }
  }

  // Save a user-created scenario
  Future<bool> saveUserScenario(Scenario scenario) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scenarios = await getUserScenarios();

      // Check if scenario already exists (for updates)
      final existingIndex = scenarios.indexWhere((s) => s.id == scenario.id);
      if (existingIndex >= 0) {
        scenarios[existingIndex] = scenario;
      } else {
        scenarios.add(scenario);
      }

      // Convert to JSON and save
      final List<Map<String, dynamic>> jsonList =
          scenarios.map((s) => s.toJson()).toList();
      await prefs.setString(_userScenariosKey, jsonEncode(jsonList));

      return true;
    } catch (e) {
      debugPrint('Error saving user scenario: $e');
      return false;
    }
  }

  // Delete a user-created scenario
  Future<bool> deleteUserScenario(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scenarios = await getUserScenarios();

      // Remove the scenario with matching ID
      scenarios.removeWhere((s) => s.id == id);

      // Convert to JSON and save
      final List<Map<String, dynamic>> jsonList =
          scenarios.map((s) => s.toJson()).toList();
      await prefs.setString(_userScenariosKey, jsonEncode(jsonList));

      return true;
    } catch (e) {
      debugPrint('Error deleting user scenario: $e');
      return false;
    }
  }
}
