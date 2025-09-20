import 'package:geolocator/geolocator.dart';

class ProduceAnalysis {
  final String id;
  final String imagePath;
  final String fruitType;
  final double ripeness;
  final double qualityScore;
  final String shelfLife;
  final List<String> recommendations;
  final DateTime analyzedAt;
  final String? detectedBrand;
  final Position? location;

  ProduceAnalysis({
    required this.id,
    required this.imagePath,
    required this.fruitType,
    required this.ripeness,
    required this.qualityScore,
    required this.shelfLife,
    required this.recommendations,
    required this.analyzedAt,
    this.detectedBrand,
    this.location,
  });

  factory ProduceAnalysis.fromJson(Map<String, dynamic> json) {
    Position? location;
    if (json['location'] != null) {
      final locationData = json['location'];
      location = Position(
        latitude: locationData['latitude'].toDouble(),
        longitude: locationData['longitude'].toDouble(),
        timestamp: DateTime.parse(locationData['timestamp']),
        accuracy: locationData['accuracy']?.toDouble() ?? 0.0,
        altitude: locationData['altitude']?.toDouble() ?? 0.0,
        heading: locationData['heading']?.toDouble() ?? 0.0,
        speed: locationData['speed']?.toDouble() ?? 0.0,
        speedAccuracy: locationData['speedAccuracy']?.toDouble() ?? 0.0,
        altitudeAccuracy: locationData['altitudeAccuracy']?.toDouble() ?? 0.0,
        headingAccuracy: locationData['headingAccuracy']?.toDouble() ?? 0.0,
      );
    }

    return ProduceAnalysis(
      id: json['id'],
      imagePath: json['imagePath'],
      fruitType: json['fruitType'],
      ripeness: json['ripeness'].toDouble(),
      qualityScore: json['qualityScore'].toDouble(),
      shelfLife: json['shelfLife'],
      recommendations: List<String>.from(json['recommendations']),
      analyzedAt: DateTime.parse(json['analyzedAt']),
      detectedBrand: json['detectedBrand'],
      location: location,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? locationJson;
    if (location != null) {
      locationJson = {
        'latitude': location!.latitude,
        'longitude': location!.longitude,
        'timestamp': location!.timestamp.toIso8601String(),
        'accuracy': location!.accuracy,
        'altitude': location!.altitude,
        'heading': location!.heading,
        'speed': location!.speed,
        'speedAccuracy': location!.speedAccuracy,
        'altitudeAccuracy': location!.altitudeAccuracy,
        'headingAccuracy': location!.headingAccuracy,
      };
    }

    return {
      'id': id,
      'imagePath': imagePath,
      'fruitType': fruitType,
      'ripeness': ripeness,
      'qualityScore': qualityScore,
      'shelfLife': shelfLife,
      'recommendations': recommendations,
      'analyzedAt': analyzedAt.toIso8601String(),
      'detectedBrand': detectedBrand,
      'location': locationJson,
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