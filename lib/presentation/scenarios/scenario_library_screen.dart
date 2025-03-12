// lib/presentation/scenarios/scenario_library_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_device_manager/data/models/device.dart';
import 'package:smart_device_manager/data/models/scenario.dart';
import 'package:smart_device_manager/data/repositories/scenario_repository.dart';
import 'package:smart_device_manager/presentation/scenarios/create_scenario_screen.dart';

class ScenarioLibraryScreen extends StatefulWidget {
  final Device device;

  const ScenarioLibraryScreen({Key? key, required this.device})
      : super(key: key);

  @override
  State<ScenarioLibraryScreen> createState() => _ScenarioLibraryScreenState();
}

class _ScenarioLibraryScreenState extends State<ScenarioLibraryScreen> {
  final ScenarioRepository _repository = ScenarioRepository();
  List<Scenario> _builtInScenarios = [];
  List<Scenario> _userScenarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load built-in scenarios
      _builtInScenarios = _repository.getBuiltInScenarios();

      // Load user scenarios
      _userScenarios = await _repository.getUserScenarios();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading scenarios: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scenario Library'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Built-in'),
              Tab(text: 'My Scenarios'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Built-in scenarios tab
                  _buildScenarioGrid(_builtInScenarios),

                  // User scenarios tab
                  _userScenarios.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.theater_comedy,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No custom scenarios yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first scenario by tapping the + button',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : _buildScenarioGrid(_userScenarios, isUserCreated: true),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            // Navigate to scenario creation screen
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CreateScenarioScreen(device: widget.device),
              ),
            );

            // Reload scenarios if we got a result back
            if (result == true) {
              _loadScenarios();
            }
          },
        ),
      ),
    );
  }

  Widget _buildScenarioGrid(List<Scenario> scenarios,
      {bool isUserCreated = false}) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: scenarios.length,
      itemBuilder: (context, index) {
        final scenario = scenarios[index];
        return _buildScenarioCard(scenario, isUserCreated: isUserCreated);
      },
    );
  }

  Widget _buildScenarioCard(Scenario scenario, {bool isUserCreated = false}) {
    return GestureDetector(
      onTap: () {
        // Apply the scenario to the device
        _applyScenario(scenario);
      },
      onLongPress: isUserCreated
          ? () {
              _showScenarioOptions(scenario);
            }
          : null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scenario image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image (or fallback color if image is missing)
                  Image.asset(
                    scenario.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // If image fails to load, show a colored box
                      final Color boxColor = _getColorFromHex(
                        scenario.settings['color'] as String? ?? '#CCCCCC',
                      );
                      return Container(color: boxColor);
                    },
                  ),

                  // Optional overlay for user-created scenarios
                  if (isUserCreated)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Custom',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Scenario details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scenario.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scenario.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyScenario(Scenario scenario) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // For custom scenarios, we'll use a special identifier format
      String scenarioValue = scenario.isUserCreated
          ? 'Custom: ${scenario.name}' // Add a prefix for custom scenarios
          : scenario.name; // Use the exact name for built-in ones

      // Update device properties based on scenario settings
      await widget.device.setProperty('active_scenario', scenarioValue);

      // Apply each setting from the scenario
      for (var entry in scenario.settings.entries) {
        await widget.device.setProperty(entry.key, entry.value);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Applied scenario: ${scenario.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to apply scenario: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });

      // Return to previous screen after applying
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  void _showScenarioOptions(Scenario scenario) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Scenario'),
                  onTap: () async {
                    Navigator.pop(context); // Close the bottom sheet
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateScenarioScreen(
                          device: widget.device,
                          scenarioToEdit: scenario,
                        ),
                      ),
                    );

                    if (result == true) {
                      _loadScenarios();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Scenario',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context); // Close the bottom sheet
                    _confirmDeleteScenario(scenario);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteScenario(Scenario scenario) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Scenario'),
          content: Text(
              'Are you sure you want to delete "${scenario.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog

                final success =
                    await _repository.deleteUserScenario(scenario.id);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scenario deleted')),
                  );
                  _loadScenarios(); // Refresh the list
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete scenario')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Helper function to convert hex color string to Color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
