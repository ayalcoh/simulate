// lib/presentation/scenarios/create_scenario_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_device_manager/config/theme.dart';
import 'package:smart_device_manager/data/models/device.dart';
import 'package:smart_device_manager/data/models/scenario.dart';
import 'package:smart_device_manager/data/repositories/scenario_repository.dart';

class CreateScenarioScreen extends StatefulWidget {
  final Device device;
  final Scenario? scenarioToEdit;

  const CreateScenarioScreen({
    Key? key,
    required this.device,
    this.scenarioToEdit,
  }) : super(key: key);

  @override
  State<CreateScenarioScreen> createState() => _CreateScenarioScreenState();
}

class _CreateScenarioScreenState extends State<CreateScenarioScreen> {
  final ScenarioRepository _repository = ScenarioRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;

  // Scenario settings
  String _selectedColor = '#2E7D32'; // Default to primary green
  int _brightness = 50;
  String _animation = 'None';
  String _animationSpeed = 'Medium';

  // Animation options from TSL
  final List<String> _animationOptions = [
    'None',
    'Wave',
    'Pulse',
    'Sway',
    'Fade'
  ];
  final List<String> _speedOptions = ['Slow', 'Medium', 'Fast'];

  @override
  void initState() {
    super.initState();

    // Check if we're editing an existing scenario
    _isEditing = widget.scenarioToEdit != null;

    if (_isEditing) {
      // Populate form with existing scenario data
      final scenario = widget.scenarioToEdit!;
      _nameController.text = scenario.name;
      _descriptionController.text = scenario.description;

      // Extract settings
      final settings = scenario.settings;
      _selectedColor = settings['color'] as String? ?? _selectedColor;
      _brightness = settings['brightness'] as int? ?? _brightness;
      _animation = settings['animation'] as String? ?? _animation;
      _animationSpeed =
          settings['animation_speed'] as String? ?? _animationSpeed;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Scenario' : 'Create Scenario'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveScenario,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview of the scenario
                    _buildPreview(),

                    const SizedBox(height: 24),

                    // Name and description
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Scenario Name',
                        hintText: 'Enter a name for your scenario',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Briefly describe your scenario',
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Scenario Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Color picker
                    _buildColorSection(),

                    const SizedBox(height: 16),

                    // Brightness slider
                    _buildSliderSection(
                      title: 'Brightness',
                      value: _brightness.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _brightness = value.round();
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Animation dropdown
                    _buildDropdownSection(
                      title: 'Animation',
                      value: _animation,
                      items: _animationOptions,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _animation = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Animation speed dropdown (only show if animation is selected)
                    if (_animation != 'None')
                      _buildDropdownSection(
                        title: 'Animation Speed',
                        value: _animationSpeed,
                        items: _speedOptions,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _animationSpeed = value;
                            });
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPreview() {
    // Convert hex to Color
    final color = _getColorFromHex(_selectedColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              _getAnimationIcon(),
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _nameController.text.isEmpty
                  ? 'New Scenario'
                  : _nameController.text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_brightness%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showColorPicker,
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _getColorFromHex(_selectedColor),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                _selectedColor,
                style: TextStyle(
                  color: _getContrastColor(_getColorFromHex(_selectedColor)),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderSection({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${value.round()}%',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: '${value.round()}%',
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              min.round().toString(),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              max.round().toString(),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 16,
              style: TextStyle(color: Colors.grey[800]),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _getColorFromHex(_selectedColor),
              onColorChanged: (Color color) {
                // Convert to hex
                final hex =
                    '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                setState(() {
                  _selectedColor = hex;
                });
              },
              pickerAreaHeightPercent: 0.8,
              displayThumbColor: true,
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius:
                  const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveScenario() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create a new scenario or update existing one
      final String id =
          _isEditing ? widget.scenarioToEdit!.id : const Uuid().v4();

      final Scenario scenario = Scenario(
        id: id,
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _isEditing
            ? widget.scenarioToEdit!.imageUrl
            : 'assets/images/scenarios/custom.jpg', // Default image for custom
        settings: {
          'color': _selectedColor,
          'brightness': _brightness,
          'animation': _animation,
          'animation_speed': _animationSpeed,
        },
        isUserCreated: true,
        createdAt: DateTime.now(),
      );

      // Save to repository
      final success = await _repository.saveUserScenario(scenario);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_isEditing
                    ? 'Scenario updated successfully'
                    : 'Scenario created successfully')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save scenario')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper function to convert hex color string to Color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // Helper function to get contrasting text color (black or white)
  Color _getContrastColor(Color backgroundColor) {
    // Calculate relative luminance
    double luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    // Return black for light colors, white for dark colors
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Helper function to get an icon based on the animation type
  IconData _getAnimationIcon() {
    switch (_animation) {
      case 'Wave':
        return Icons.waves;
      case 'Pulse':
        return Icons.flash_on;
      case 'Sway':
        return Icons.air;
      case 'Fade':
        return Icons.blur_on;
      default:
        return Icons.lightbulb;
    }
  }
}
