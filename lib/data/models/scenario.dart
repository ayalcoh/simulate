// lib/data/models/scenario.dart

class Scenario {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final Map<String, dynamic> settings;
  final bool isUserCreated;
  final DateTime? createdAt;

  Scenario({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.settings,
    this.isUserCreated = false,
    this.createdAt,
  });

  // Create from JSON (useful for storage/retrieval)
  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      settings: json['settings'],
      isUserCreated: json['isUserCreated'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'settings': settings,
      'isUserCreated': isUserCreated,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
