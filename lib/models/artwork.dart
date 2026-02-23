class Artwork {
  final int id;
  final String title;
  final DateTime createdAt;
  final int gridSize;
  final List<int> pixels; // Store color values as integers
  final int backgroundColorValue;

  Artwork({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.gridSize,
    required this.pixels,
    required this.backgroundColorValue,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'gridSize': gridSize,
      'pixels': pixels,
      'backgroundColorValue': backgroundColorValue,
    };
  }

  // Create from JSON
  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      gridSize: json['gridSize'],
      pixels: List<int>.from(json['pixels']),
      backgroundColorValue: json['backgroundColorValue'],
    );
  }
}
