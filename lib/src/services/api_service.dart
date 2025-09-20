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
import '../config/api_config.dart';
import 'gemini_vision_service.dart';
import 'brand_tracking_service.dart';
import 'supabase_service.dart';
import 'data_insertion_service.dart';
import 'food_bank_cache_service.dart';
import '../utils/performance_monitor.dart';

class ApiService {
  static const String baseUrl = ApiConfig.freshTrackBaseUrl;
  static const Duration timeout = ApiConfig.apiTimeout;

  // Authentication
  static Future<bool> loginSupplier(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication logic
    return email == 'sunkist@env.com' && password == 'demo123';
  }

  static Future<bool> loginConsumer(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication logic
    return email == 'james@env.com' && password == 'demo123';
  }

  // Produce Analysis with Brand Detection
  static Future<ProduceAnalysis> analyzeProduceImage(String imagePath) async {
    try {
      // Get current location for tracking
      final location = await getCurrentLocation();

      // Simulate AI analysis delay
      await Future.delayed(const Duration(seconds: 1));

      // Get mock analysis (in real implementation, this would be actual AI analysis)
      final baseAnalysis = ProduceAnalysis.mockAppleAnalysis;

      // Run brand detection in parallel (doesn't block main analysis)
      String? detectedBrand;
      try {
        detectedBrand = await GeminiVisionService.detectFruitBrand(imagePath);
      } catch (e) {
        print('Brand detection failed: $e');
        detectedBrand = null;
      }

      // Create enhanced analysis with brand and location data
      final enhancedAnalysis = ProduceAnalysis(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        imagePath: imagePath,
        fruitType: baseAnalysis.fruitType,
        ripeness: baseAnalysis.ripeness,
        qualityScore: baseAnalysis.qualityScore,
        shelfLife: baseAnalysis.shelfLife,
        recommendations: baseAnalysis.recommendations,
        analyzedAt: DateTime.now(),
        detectedBrand: detectedBrand,
        location: location,
      );

      // Save brand tracking data if brand was detected
      if (detectedBrand != null) {
        // Save locally only - Supabase sync is now handled manually with real scores
        await BrandTrackingService.saveBrandFromAnalysis(
          brandName: detectedBrand,
          fruitType: baseAnalysis.fruitType,
          timestamp: DateTime.now(),
          location: location,
        );

        // NOTE: Supabase sync disabled here - now handled in PhotoAnalysisScreen
        // with real GCP ripeness scores instead of mock data
      }

      return enhancedAnalysis;

    } catch (e) {
      print('Error in produce analysis: $e');
      // Fallback to basic analysis without brand detection
      return ProduceAnalysis.mockAppleAnalysis;
    }
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

  // Location-based Food Bank Search using Google Places API (OPTIMIZED)
  static Future<List<FoodBank>> searchFoodBanksByLocation({
    required double latitude,
    required double longitude,
    double radiusMiles = 10.0,
  }) async {
    return PerformanceMonitor.timeAsync(
      'FoodBankSearch',
      () async {
        // Check cache first
        final cachedBanks = await FoodBankCacheService.getCachedFoodBanks(latitude, longitude);
        if (cachedBanks != null) {
          PerformanceMonitor.logMetric('Cache Hit', cachedBanks.length, ' results');
          return cachedBanks;
        }
        
        PerformanceMonitor.logMetric('Cache Miss', 'Loading from API');
        return await _performApiSearch(latitude, longitude, radiusMiles);
      },
    );
  }

  static Future<List<FoodBank>> _performApiSearch(
    double latitude,
    double longitude,
    double radiusMiles,
  ) async {

    // Check if Google Places API is configured
    if (!ApiConfig.isGoogleApiKeyConfigured) {
      PerformanceMonitor.logMetric('API Status', 'Using Mock Data');
      final mockBanks = _generateNearbyFoodBanks(latitude, longitude, radiusMiles);
      await FoodBankCacheService.cacheFoodBanks(mockBanks, latitude, longitude);
      return mockBanks;
    }

    try {
      PerformanceMonitor.logMetric('API Status', 'Using Google Places API');
      
      // Convert miles to meters for Google Places API
      final radiusMeters = (radiusMiles * 1609.34).round();

      // Use the original comprehensive search queries for real food banks
      final searchQueries = ApiConfig.foodBankSearchQueries;

      PerformanceMonitor.logMetric('Search Queries', searchQueries.length, ' comprehensive search terms');

      // OPTIMIZATION: Run queries in parallel instead of sequentially
      final futures = searchQueries.map((query) => 
        _searchPlacesByQuery(
          query: query,
          latitude: latitude,
          longitude: longitude,
          radius: radiusMeters,
        )
      );

      final results = await Future.wait(futures);
      final List<FoodBank> allFoodBanks = results.expand((banks) => banks).toList();

      PerformanceMonitor.logMetric('Total Results', allFoodBanks.length, ' before deduplication');

      // Remove duplicates based on place_id and sort by distance
      final uniqueBanks = <String, FoodBank>{};
      for (final bank in allFoodBanks) {
        if (!uniqueBanks.containsKey(bank.id)) {
          uniqueBanks[bank.id] = bank;
        }
      }

      final result = uniqueBanks.values.toList();
      result.sort((a, b) => a.distanceMiles.compareTo(b.distanceMiles));

      final finalResult = result.take(ApiConfig.maxFoodBankResults).toList();
      
      PerformanceMonitor.logMetric('Final Results', finalResult.length, ' unique food banks');
      
      // Cache the results
      await FoodBankCacheService.cacheFoodBanks(finalResult, latitude, longitude);
      
      return finalResult;

    } catch (e) {
      PerformanceMonitor.logMetric('API Error', e.toString());
      print('Error searching food banks with Google Places API: $e');
      // Fallback to mock data if API fails
      final fallbackBanks = _generateNearbyFoodBanks(latitude, longitude, radiusMiles);
      await FoodBankCacheService.cacheFoodBanks(fallbackBanks, latitude, longitude);
      return fallbackBanks;
    }
  }

  // Search places using Google Places Text Search API
  static Future<List<FoodBank>> _searchPlacesByQuery({
    required String query,
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    final uri = Uri.parse('${ApiConfig.googlePlacesBaseUrl}/textsearch/json').replace(
      queryParameters: {
        'query': query,
        'location': '$latitude,$longitude',
        'radius': radius.toString(),
        'key': ApiConfig.googlePlacesApiKey,
        'type': 'establishment',
      },
    );

    final response = await http.get(uri).timeout(timeout);

    if (response.statusCode != 200) {
      throw Exception('Google Places API request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final results = data['results'] as List<dynamic>;

    final foodBanks = <FoodBank>[];

    // Process all results but limit Place Details API calls for performance
    final limitedResults = results.take(6).toList(); // Limit to 6 results per query for details
    
    for (int i = 0; i < results.length; i++) {
      final place = results[i];
      try {
        final placeId = place['place_id'] as String;
        final name = place['name'] as String;
        final address = place['formatted_address'] as String? ?? 'Address not available';

        final geometry = place['geometry'];
        final location = geometry['location'];
        final placeLat = location['lat'] as double;
        final placeLng = location['lng'] as double;

        // Calculate distance
        final distance = _calculateDistance(latitude, longitude, placeLat, placeLng);

        // Get detailed info for first 6 results, basic info for others
        Map<String, String?> details = {};
        if (i < 6) {
          details = await _getPlaceDetails(placeId);
        }

        final foodBank = FoodBank(
          id: placeId,
          name: name,
          address: address,
          latitude: placeLat,
          longitude: placeLng,
          distanceMiles: distance,
          availableProduce: 'Contact for current inventory',
          operatingHours: details['hours'] ?? 'Contact for hours',
          phoneNumber: details['phone'],
          website: details['website'],
        );

        foodBanks.add(foodBank);
      } catch (e) {
        print('Error parsing place data: $e');
        continue;
      }
    }

    return foodBanks;
  }

  // Load place details on-demand (when user taps a marker)
  static Future<FoodBank> loadFoodBankDetails(FoodBank foodBank) async {
    try {
      final details = await _getPlaceDetails(foodBank.id);
      
      return FoodBank(
        id: foodBank.id,
        name: foodBank.name,
        address: foodBank.address,
        latitude: foodBank.latitude,
        longitude: foodBank.longitude,
        distanceMiles: foodBank.distanceMiles,
        availableProduce: foodBank.availableProduce,
        operatingHours: details['hours'] ?? foodBank.operatingHours,
        phoneNumber: details['phone'] ?? foodBank.phoneNumber,
        website: details['website'] ?? foodBank.website,
      );
    } catch (e) {
      print('Error loading food bank details: $e');
      return foodBank; // Return original if details fail
    }
  }

  // Get detailed information about a place
  static Future<Map<String, String?>> _getPlaceDetails(String placeId) async {
    try {
      final uri = Uri.parse('${ApiConfig.googlePlacesBaseUrl}/details/json').replace(
        queryParameters: {
          'place_id': placeId,
          'fields': 'opening_hours,formatted_phone_number,website',
          'key': ApiConfig.googlePlacesApiKey,
        },
      );

      final response = await http.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'];

        String? hours;
        if (result['opening_hours'] != null) {
          final weekdayText = result['opening_hours']['weekday_text'] as List<dynamic>?;
          if (weekdayText != null && weekdayText.isNotEmpty) {
            hours = weekdayText.take(3).join('\n'); // Show first 3 days
          }
        }

        return {
          'hours': hours,
          'phone': result['formatted_phone_number'] as String?,
          'website': result['website'] as String?,
        };
      }
    } catch (e) {
      print('Error getting place details: $e');
    }

    return {
      'hours': null,
      'phone': null,
      'website': null,
    };
  }

  // Calculate distance between two points in miles
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 3959.0; // Earth's radius in miles

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Public method to sync brand data to Supabase
  static Future<void> syncBrandToSupabase({
    required String brandName,
    required double ripenessScore,
    required DateTime analyzedAt,
    Position? location,
    String? fruitType,
  }) async {
    return _syncBrandToSupabase(
      brandName: brandName,
      ripenessScore: ripenessScore,
      analyzedAt: analyzedAt,
      location: location,
      fruitType: fruitType,
    );
  }

  /// Background sync of brand data to Supabase
  static Future<void> _syncBrandToSupabase({
    required String brandName,
    required double ripenessScore,
    required DateTime analyzedAt,
    Position? location,
    String? fruitType,
  }) async {
    // Run in background, don't block main thread
    Future.microtask(() async {
      try {
        if (!SupabaseService.isReady) {
          print('Supabase not configured, skipping sync');
          return;
        }

        final success = await SupabaseService.insertBrandData(
          brandName: brandName,
          ripenessScore: ripenessScore,
          analyzedAt: analyzedAt,
          location: location,
          fruitType: fruitType,
        );

        if (success) {
          print('Successfully synced brand data to Supabase: $brandName');
        } else {
          print('Failed to sync brand data to Supabase: $brandName');
        }
      } catch (e) {
        print('Error syncing brand data to Supabase: $e');
      }
    });
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

  // Development Helper: Insert Halos dummy data
  static Future<bool> insertHalosDummyData() async {
    try {
      print('Starting Halos dummy data insertion...');
      final success = await DataInsertionService.insertHalosDummyData();
      if (success) {
        print('Halos dummy data inserted successfully!');
      } else {
        print('Failed to insert Halos dummy data');
      }
      return success;
    } catch (e) {
      print('Error inserting Halos dummy data: $e');
      return false;
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