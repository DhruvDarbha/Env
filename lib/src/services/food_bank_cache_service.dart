import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_bank.dart';

class FoodBankCacheService {
  static const String _cacheKey = 'food_bank_cache';
  static const Duration _cacheExpiration = Duration(hours: 24); // Cache for 24 hours
  
  /// Get cached food banks for a location
  static Future<List<FoodBank>?> getCachedFoodBanks(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_cacheKey);
      
      if (cacheData == null) return null;
      
      final cache = jsonDecode(cacheData) as Map<String, dynamic>;
      final cachedLat = cache['latitude'] as double;
      final cachedLng = cache['longitude'] as double;
      final timestamp = DateTime.parse(cache['timestamp'] as String);
      
      // Check if cache is still valid (within 24 hours and same location)
      final now = DateTime.now();
      final isExpired = now.difference(timestamp) > _cacheExpiration;
      final isSameLocation = _isNearbyLocation(latitude, longitude, cachedLat, cachedLng);
      
      if (isExpired || !isSameLocation) {
        await _clearCache();
        return null;
      }
      
      // Parse cached food banks
      final foodBanksJson = cache['food_banks'] as List<dynamic>;
      return foodBanksJson.map((json) => FoodBank.fromJson(json)).toList();
      
    } catch (e) {
      print('Error reading food bank cache: $e');
      return null;
    }
  }
  
  /// Cache food banks for a location
  static Future<void> cacheFoodBanks(
    List<FoodBank> foodBanks, 
    double latitude, 
    double longitude
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final cacheData = {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
        'food_banks': foodBanks.map((fb) => fb.toJson()).toList(),
      };
      
      await prefs.setString(_cacheKey, jsonEncode(cacheData));
      print('Cached ${foodBanks.length} food banks for location');
      
    } catch (e) {
      print('Error caching food banks: $e');
    }
  }
  
  /// Clear the cache
  static Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (e) {
      print('Error clearing food bank cache: $e');
    }
  }
  
  /// Check if two locations are nearby (within 1 mile)
  static bool _isNearbyLocation(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 3959.0; // Earth's radius in miles
    const double maxCacheDistance = 1.0; // 1 mile radius for cache
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;
    
    return distance <= maxCacheDistance;
  }
  
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}

