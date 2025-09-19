import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../models/user.dart';
import '../models/produce_analysis.dart';
import '../models/recipe.dart';
import '../models/food_bank.dart';
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'https://api.freshtrack.com';
  static const Duration timeout = Duration(seconds: 30);

  // Authentication
  static Future<bool> loginSupplier(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication logic
    return email == 'supplier@freshtrack.com' && password == 'demo123';
  }

  static Future<bool> loginConsumer(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication logic
    return email == 'james@savr.com' && password == 'demo123';
  }

  // Produce Analysis
  static Future<ProduceAnalysis> analyzeProduceImage(String imagePath) async {
    // Simulate AI analysis delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock analysis
    return ProduceAnalysis.mockAppleAnalysis;
  }

  // Recipes
  static Future<List<Recipe>> searchRecipes(String query) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return filtered mock recipes
    final recipes = Recipe.mockRecipes;
    if (query.isEmpty) return recipes;

    return recipes.where((recipe) =>
      recipe.name.toLowerCase().contains(query.toLowerCase()) ||
      recipe.ingredients.any((ingredient) =>
        ingredient.toLowerCase().contains(query.toLowerCase())
      )
    ).toList();
  }

  // Food Banks
  static Future<List<FoodBank>> searchFoodBanks(String zipCode) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return mock food banks
    return FoodBank.mockFoodBanks;
  }

  // Location-based Food Bank Search
  static Future<List<FoodBank>> searchFoodBanksByLocation({
    required double latitude,
    required double longitude,
    double radiusMiles = 10.0,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate mock food banks based on location
    return _generateNearbyFoodBanks(latitude, longitude, radiusMiles);
  }

  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  static Future<Position?> getLocationFromZipCode(String zipCode) async {
    try {
      // Convert zip code to coordinates
      List<Location> locations = await locationFromAddress(zipCode);
      if (locations.isNotEmpty) {
        return Position(
          latitude: locations.first.latitude,
          longitude: locations.first.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } catch (e) {
      print('Error converting zipcode to location: $e');
    }
    return null;
  }

  static List<FoodBank> _generateNearbyFoodBanks(double lat, double lng, double radiusMiles) {
    // Generate realistic food banks around the given location
    final random = DateTime.now().millisecondsSinceEpoch;
    final banks = <FoodBank>[];

    // Create a variety of food banks at different distances and directions
    final bankTemplates = [
      {
        'name': 'Community Food Bank',
        'produce': 'Fresh vegetables, fruits',
        'hours': 'Mon-Fri 9AM-5PM',
        'phone': '(555) 123-4567',
      },
      {
        'name': 'Harvest Hope Food Pantry',
        'produce': 'Organic produce, herbs',
        'hours': 'Tue-Sat 10AM-4PM',
        'phone': '(555) 234-5678',
      },
      {
        'name': 'Local Pantry Network',
        'produce': 'Seasonal fruits, root vegetables',
        'hours': 'Wed-Sun 8AM-6PM',
        'phone': '(555) 345-6789',
      },
      {
        'name': 'Green Valley Food Bank',
        'produce': 'Farm-fresh produce, leafy greens',
        'hours': 'Mon-Sat 7AM-7PM',
        'phone': '(555) 456-7890',
      },
      {
        'name': 'Unity Food Distribution',
        'produce': 'Mixed vegetables, fruits, grains',
        'hours': 'Thu-Sun 9AM-3PM',
        'phone': '(555) 567-8901',
      },
    ];

    for (int i = 0; i < bankTemplates.length; i++) {
      final template = bankTemplates[i];

      // Generate coordinates within radius
      final angle = (i * 72.0) * (3.14159 / 180); // Distribute evenly in circle
      final distance = (i + 1) * 0.5; // Varying distances

      final offsetLat = lat + (distance / 69.0) * math.cos(angle);
      final offsetLng = lng + (distance / (69.0 * math.cos(lat * 3.14159 / 180))) * math.sin(angle);

      banks.add(FoodBank(
        id: 'fb_${String.fromCharCode(65 + i)}${random + i}',
        name: template['name']!,
        address: '${100 + i * 50} ${['Main St', 'Oak Ave', 'Pine St', 'Elm Dr', 'Cedar Ln'][i]}, Local City, ST ${10000 + i * 111}',
        latitude: offsetLat,
        longitude: offsetLng,
        distanceMiles: distance,
        availableProduce: template['produce']!,
        operatingHours: template['hours']!,
        phoneNumber: template['phone']!,
      ));
    }

    // Sort by distance
    banks.sort((a, b) => a.distanceMiles.compareTo(b.distanceMiles));

    return banks;
  }

  // Chat
  static Future<Message> sendChatMessage(String message) async {
    // Simulate AI response delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate mock response based on input
    String response = _generateChatResponse(message);

    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
    );
  }

  static String _generateChatResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('quality') || message.contains('fresh')) {
      return "I understand you're asking about produce quality. Based on your question, I'd recommend checking the ripeness indicators and storage conditions. Would you like me to analyze a photo of your produce?";
    } else if (message.contains('recipe') || message.contains('cook')) {
      return "I can help you find recipes based on your available produce! What ingredients do you have on hand? I can suggest some delicious and nutritious recipes.";
    } else if (message.contains('food bank') || message.contains('donate')) {
      return "I can help you find local food banks in your area. If you have surplus produce to donate, I can connect you with organizations that would appreciate fresh donations.";
    } else if (message.contains('storage') || message.contains('store')) {
      return "Proper storage is key to maintaining produce quality! Different fruits and vegetables have specific storage requirements. Would you like storage tips for a particular type of produce?";
    } else {
      return "I'm here to help with all your produce-related questions! I can assist with quality analysis, recipe suggestions, storage tips, and connecting you with local food resources. What would you like to know?";
    }
  }

  // Generic HTTP methods for future API integration
  static Future<http.Response> _get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.get(uri).timeout(timeout);
  }

  static Future<http.Response> _post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ).timeout(timeout);
  }
}