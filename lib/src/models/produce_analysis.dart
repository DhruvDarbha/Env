class ProduceAnalysis {
  final String id;
  final String imagePath;
  final String fruitType;
  final double ripeness;
  final double qualityScore;
  final String shelfLife;
  final List<String> recommendations;
  final DateTime analyzedAt;

  ProduceAnalysis({
    required this.id,
    required this.imagePath,
    required this.fruitType,
    required this.ripeness,
    required this.qualityScore,
    required this.shelfLife,
    required this.recommendations,
    required this.analyzedAt,
  });

  factory ProduceAnalysis.fromJson(Map<String, dynamic> json) {
    return ProduceAnalysis(
      id: json['id'],
      imagePath: json['imagePath'],
      fruitType: json['fruitType'],
      ripeness: json['ripeness'].toDouble(),
      qualityScore: json['qualityScore'].toDouble(),
      shelfLife: json['shelfLife'],
      recommendations: List<String>.from(json['recommendations']),
      analyzedAt: DateTime.parse(json['analyzedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'fruitType': fruitType,
      'ripeness': ripeness,
      'qualityScore': qualityScore,
      'shelfLife': shelfLife,
      'recommendations': recommendations,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  // Mock data for demo
  static ProduceAnalysis get mockAppleAnalysis => ProduceAnalysis(
    id: 'apple_001',
    imagePath: 'assets/images/fresh-apple.jpg',
    fruitType: 'Apple',
    ripeness: 85.0,
    qualityScore: 4.2,
    shelfLife: '5-7 days',
    recommendations: [
      'Store in refrigerator at 35-40°F',
      'Use within 5-7 days for best quality',
      'Perfect for fresh eating and baking',
      'Keep away from other fruits to prevent over-ripening',
    ],
    analyzedAt: DateTime.now(),
  );
}