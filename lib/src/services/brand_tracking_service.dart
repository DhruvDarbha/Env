import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class BrandEntry {
  final String id;
  final String brandName;
  final String fruitType;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String? locationDescription;

  BrandEntry({
    required this.id,
    required this.brandName,
    required this.fruitType,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.locationDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brandName': brandName,
      'fruitType': fruitType,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationDescription': locationDescription,
    };
  }

  factory BrandEntry.fromJson(Map<String, dynamic> json) {
    return BrandEntry(
      id: json['id'],
      brandName: json['brandName'],
      fruitType: json['fruitType'],
      timestamp: DateTime.parse(json['timestamp']),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      locationDescription: json['locationDescription'],
    );
  }
}

class BrandTrackingService {
  static const String _storageKey = 'brand_entries';
  static const int _maxEntries = 1000; // Limit storage to last 1000 entries

  /// Save a brand detection entry
  static Future<void> saveBrandEntry(BrandEntry entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingEntries = await getBrandHistory();

      // Add new entry at the beginning
      existingEntries.insert(0, entry);

      // Limit the number of stored entries
      if (existingEntries.length > _maxEntries) {
        existingEntries.removeRange(_maxEntries, existingEntries.length);
      }

      // Convert to JSON and save
      final jsonList = existingEntries.map((entry) => entry.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(_storageKey, jsonString);

      print('Saved brand entry: ${entry.brandName} (${entry.fruitType})');
    } catch (e) {
      print('Error saving brand entry: $e');
    }
  }

  /// Get all brand history entries
  static Future<List<BrandEntry>> getBrandHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => BrandEntry.fromJson(json)).toList();
    } catch (e) {
      print('Error loading brand history: $e');
      return [];
    }
  }

  /// Get brand entries by date range
  static Future<List<BrandEntry>> getBrandsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final allEntries = await getBrandHistory();
    return allEntries.where((entry) {
      return entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
    }).toList();
  }

  /// Get brand frequency statistics
  static Future<Map<String, int>> getBrandFrequency() async {
    final allEntries = await getBrandHistory();
    final frequency = <String, int>{};

    for (final entry in allEntries) {
      frequency[entry.brandName] = (frequency[entry.brandName] ?? 0) + 1;
    }

    return frequency;
  }

  /// Get most recent entries (last N days)
  static Future<List<BrandEntry>> getRecentEntries({int days = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return getBrandsByDateRange(cutoffDate, DateTime.now());
  }

  /// Clear all brand tracking data
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      print('Cleared all brand tracking data');
    } catch (e) {
      print('Error clearing brand data: $e');
    }
  }

  /// Get total number of stored entries
  static Future<int> getEntryCount() async {
    final entries = await getBrandHistory();
    return entries.length;
  }

  /// Create a brand entry from analysis data
  static BrandEntry createFromAnalysis({
    required String brandName,
    required String fruitType,
    required DateTime timestamp,
    Position? location,
  }) {
    return BrandEntry(
      id: '${timestamp.millisecondsSinceEpoch}_${brandName}_${fruitType}',
      brandName: brandName,
      fruitType: fruitType,
      timestamp: timestamp,
      latitude: location?.latitude,
      longitude: location?.longitude,
      locationDescription: null, // Will be filled later if needed
    );
  }

  /// Save brand detection from produce analysis
  static Future<void> saveBrandFromAnalysis({
    required String brandName,
    required String fruitType,
    required DateTime timestamp,
    Position? location,
  }) async {
    final entry = createFromAnalysis(
      brandName: brandName,
      fruitType: fruitType,
      timestamp: timestamp,
      location: location,
    );

    await saveBrandEntry(entry);
  }
}