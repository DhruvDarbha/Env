class FoodBank {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceMiles;
  final String availableProduce;
  final String operatingHours;
  final String? phoneNumber;
  final String? website;

  FoodBank({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceMiles,
    required this.availableProduce,
    required this.operatingHours,
    this.phoneNumber,
    this.website,
  });

  factory FoodBank.fromJson(Map<String, dynamic> json) {
    return FoodBank(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      distanceMiles: json['distanceMiles'].toDouble(),
      availableProduce: json['availableProduce'],
      operatingHours: json['operatingHours'],
      phoneNumber: json['phoneNumber'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distanceMiles': distanceMiles,
      'availableProduce': availableProduce,
      'operatingHours': operatingHours,
      'phoneNumber': phoneNumber,
      'website': website,
    };
  }

  String get distanceString => '${distanceMiles.toStringAsFixed(1)} miles';

  // Mock food banks for demo
  static List<FoodBank> get mockFoodBanks => [
    FoodBank(
      id: 'fb_001',
      name: 'Community Food Bank',
      address: '123 Main St, Your City, ST 12345',
      latitude: 37.7749,
      longitude: -122.4194,
      distanceMiles: 0.8,
      availableProduce: 'Fresh vegetables, fruits',
      operatingHours: 'Mon-Fri 9AM-5PM',
      phoneNumber: '(555) 123-4567',
    ),
    FoodBank(
      id: 'fb_002',
      name: 'Harvest Hope',
      address: '456 Oak Ave, Your City, ST 12345',
      latitude: 37.7849,
      longitude: -122.4094,
      distanceMiles: 1.2,
      availableProduce: 'Organic produce, herbs',
      operatingHours: 'Tue-Sat 10AM-4PM',
      phoneNumber: '(555) 234-5678',
    ),
    FoodBank(
      id: 'fb_003',
      name: 'Local Pantry Network',
      address: '789 Pine St, Your City, ST 12345',
      latitude: 37.7949,
      longitude: -122.3994,
      distanceMiles: 2.1,
      availableProduce: 'Seasonal fruits, root vegetables',
      operatingHours: 'Wed-Sun 8AM-6PM',
      phoneNumber: '(555) 345-6789',
    ),
  ];
}