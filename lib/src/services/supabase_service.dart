import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../config/api_config.dart';

class SupabaseService {
  static SupabaseClient? _client;

  /// Initialize Supabase client
  static Future<void> initialize() async {
    if (!ApiConfig.isSupabaseConfigured) {
      print('Supabase not configured, skipping initialization');
      return;
    }

    try {
      await Supabase.initialize(
        url: ApiConfig.supabaseUrl,
        anonKey: ApiConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      print('Supabase initialized successfully');
    } catch (e) {
      print('Error initializing Supabase: $e');
    }
  }

  /// Get Supabase client
  static SupabaseClient? get client => _client;

  /// Check if Supabase is ready
  static bool get isReady => _client != null && ApiConfig.isSupabaseConfigured;

  /// Sanitize brand name for table naming
  static String _sanitizeBrandName(String brandName) {
    return brandName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  /// Get table name for a brand
  static String _getBrandTableName(String brandName) {
    final sanitized = _sanitizeBrandName(brandName);
    return '${sanitized}_data';
  }

  /// Create a new brand table if it doesn't exist using standardized schema
  static Future<bool> createBrandTable(String brandName) async {
    if (!isReady) {
      print('Supabase not ready, cannot create table');
      return false;
    }

    try {
      final tableName = _getBrandTableName(brandName);

      // Check if table already exists by trying to query it
      try {
        await _client!.from(tableName).select('id').limit(1);
        print('Table $tableName already exists');
        return true;
      } catch (e) {
        // Table doesn't exist, create it using our standardized function
        print('Table $tableName does not exist, creating with standard schema...');
      }

      // Use the standardized create_brand_table function
      try {
        final result = await _client!.rpc('create_brand_table', params: {
          'brand_name': brandName,
        });

        final createdTableName = result as String;
        print('Successfully created table: $createdTableName');

        // Force schema cache refresh by restarting the client
        print('Refreshing Supabase schema cache...');
        await Future.delayed(const Duration(seconds: 2));

        return true;
      } catch (rpcError) {
        print('Failed to create table using create_brand_table function: $rpcError');
        print('Please run BRAND_TABLE_SCHEMA.sql in your Supabase SQL Editor first.');
        return false;
      }
    } catch (e) {
      print('Error creating brand table for $brandName: $e');
      return false;
    }
  }

  /// Insert brand data into the appropriate table
  static Future<bool> insertBrandData({
    required String brandName,
    required double ripenessScore,
    required DateTime analyzedAt,
    Position? location,
    String? fruitType,
    double? latitude,
    double? longitude,
    String? locationDescription,
  }) async {
    if (!isReady) {
      print('Supabase not ready, cannot insert data');
      return false;
    }

    try {
      final tableName = _getBrandTableName(brandName);

      // Ensure table exists first
      final tableCreated = await createBrandTable(brandName);
      if (!tableCreated) {
        print('Failed to create table for brand: $brandName');
        return false;
      }

      // Prepare data for insertion
      final data = {
        'ripeness_score': ripenessScore,
        'analyzed_at': analyzedAt.toIso8601String(),
        'fruit_type': fruitType,
      };

      // Add location data if available
      if (location != null) {
        data['latitude'] = location.latitude;
        data['longitude'] = location.longitude;
        // Optional: Add location description (city, state)
        data['location_description'] = await _getLocationDescription(location);
      } else if (latitude != null && longitude != null) {
        // Use provided lat/lng directly
        data['latitude'] = latitude;
        data['longitude'] = longitude;
        data['location_description'] = locationDescription;
      }

      // Insert into brand-specific table with retry logic for schema cache issues
      try {
        await _client!.from(tableName).insert(data);
        print('Successfully inserted data into $tableName');
        return true;
      } catch (cacheError) {
        if (cacheError.toString().contains('schema cache')) {
          print('Schema cache issue detected, retrying in 3 seconds...');
          await Future.delayed(const Duration(seconds: 3));

          // Retry the insertion
          await _client!.from(tableName).insert(data);
          print('Successfully inserted data into $tableName (after retry)');
          return true;
        } else {
          rethrow;
        }
      }
    } catch (e) {
      print('Error inserting brand data: $e');
      return false;
    }
  }

  /// Get location description from coordinates (optional)
  static Future<String?> _getLocationDescription(Position location) async {
    try {
      // This would typically use a geocoding service
      // For now, return a simple format
      return '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
    } catch (e) {
      print('Error getting location description: $e');
      return null;
    }
  }

  /// Sync local brand data to Supabase
  static Future<int> syncLocalBrandData(List<BrandDataEntry> localEntries) async {
    if (!isReady) {
      print('Supabase not ready, cannot sync data');
      return 0;
    }

    int syncedCount = 0;

    for (final entry in localEntries) {
      try {
        final success = await insertBrandData(
          brandName: entry.brandName,
          ripenessScore: entry.ripenessScore,
          analyzedAt: entry.analyzedAt,
          location: entry.location,
          fruitType: entry.fruitType,
        );

        if (success) {
          syncedCount++;
        }
      } catch (e) {
        print('Error syncing entry: $e');
      }
    }

    print('Synced $syncedCount out of ${localEntries.length} entries');
    return syncedCount;
  }

  /// Get brand analytics from a specific brand table
  static Future<Map<String, dynamic>?> getBrandAnalytics(String brandName) async {
    if (!isReady) {
      print('Supabase not ready, cannot get analytics');
      return null;
    }

    try {
      final tableName = _getBrandTableName(brandName);

      // Get basic statistics
      final response = await _client!
          .from(tableName)
          .select('ripeness_score, analyzed_at, latitude, longitude')
          .order('analyzed_at', ascending: false);

      if (response.isEmpty) {
        return null;
      }

      final data = response as List<dynamic>;
      final ripenessScores = data.map((item) => item['ripeness_score'] as double).toList();

      return {
        'brand_name': brandName,
        'total_entries': data.length,
        'average_ripeness': ripenessScores.reduce((a, b) => a + b) / ripenessScores.length,
        'max_ripeness': ripenessScores.reduce((a, b) => a > b ? a : b),
        'min_ripeness': ripenessScores.reduce((a, b) => a < b ? a : b),
        'latest_entry': data.first['analyzed_at'],
      };
    } catch (e) {
      print('Error getting brand analytics: $e');
      return null;
    }
  }

  /// List all brand tables
  static Future<List<String>> getAllBrandNames() async {
    if (!isReady) {
      return [];
    }

    try {
      // Query for tables ending with '_data'
      final response = await _client!.rpc('get_brand_tables');
      return List<String>.from(response ?? []);
    } catch (e) {
      print('Error getting brand names: $e');
      return [];
    }
  }
}

/// Data class for local entries to sync
class BrandDataEntry {
  final String brandName;
  final double ripenessScore;
  final DateTime analyzedAt;
  final Position? location;
  final String? fruitType;

  BrandDataEntry({
    required this.brandName,
    required this.ripenessScore,
    required this.analyzedAt,
    this.location,
    this.fruitType,
  });
}