import '../services/supabase_service.dart';
import '../models/supplier_analytics.dart';

class SupplierAnalyticsService {
  /// Extract table name from supplier email (e.g., sunkist@env.com -> sunkist_data)
  static String getTableNameFromEmail(String email) {
    final username = email.split('@').first.toLowerCase();
    return '${username}_data';
  }

  /// Get ripeness scores over time for the supplier
  static Future<List<RipenessDataPoint>> getRipenessScoresOverTime(String supplierEmail) async {
    try {
      final tableName = getTableNameFromEmail(supplierEmail);
      final data = await SupabaseService.getSupplierData(tableName);

      final ripenessPoints = <RipenessDataPoint>[];

      for (final item in data) {
        if (item['analyzed_at'] != null && item['ripeness_score'] != null) {
          ripenessPoints.add(RipenessDataPoint(
            date: DateTime.parse(item['analyzed_at']),
            ripenessScore: (item['ripeness_score'] as num).toDouble(),
          ));
        }
      }

      // Sort by date
      ripenessPoints.sort((a, b) => a.date.compareTo(b.date));

      return ripenessPoints;
    } catch (e) {
      print('Error getting ripeness scores: $e');
      return [];
    }
  }

  /// Calculate average shelf life and return data points for line graph
  static Future<List<ShelfLifeDataPoint>> getAverageShelfLifeOverTime(String supplierEmail) async {
    try {
      final tableName = getTableNameFromEmail(supplierEmail);
      final data = await SupabaseService.getSupplierData(tableName);

      // Group data by date and calculate average shelf life
      final Map<String, List<double>> groupedData = {};

      for (final item in data) {
        if (item['analyzed_at'] != null && item['ripeness_score'] != null) {
          final date = DateTime.parse(item['analyzed_at']);
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final ripenessScore = (item['ripeness_score'] as num).toDouble();

          // Convert ripeness score to estimated shelf life
          // Lower ripeness score = more ripe = shorter shelf life
          // Scale: 0-3 very ripe (1-2 days), 3-7 just ripe (3-5 days), 7-15 unripe (6-10 days)
          double shelfLife;
          if (ripenessScore <= 3) {
            shelfLife = 1.5; // 1-2 days average
          } else if (ripenessScore <= 7) {
            shelfLife = 4.0; // 3-5 days average
          } else {
            shelfLife = 8.0; // 6-10 days average
          }

          groupedData.putIfAbsent(dateKey, () => []);
          groupedData[dateKey]!.add(shelfLife);
        }
      }

      final shelfLifePoints = <ShelfLifeDataPoint>[];

      // Calculate average for each date
      for (final entry in groupedData.entries) {
        final dateKey = entry.key;
        final shelfLives = entry.value;
        final averageShelfLife = shelfLives.reduce((a, b) => a + b) / shelfLives.length;

        shelfLifePoints.add(ShelfLifeDataPoint(
          date: DateTime.parse(dateKey),
          averageShelfLife: averageShelfLife,
        ));
      }

      // Sort by date
      shelfLifePoints.sort((a, b) => a.date.compareTo(b.date));

      return shelfLifePoints;
    } catch (e) {
      print('Error getting shelf life data: $e');
      return [];
    }
  }

  /// Get summary statistics for the supplier
  static Future<SupplierSummary> getSupplierSummary(String supplierEmail) async {
    try {
      final tableName = getTableNameFromEmail(supplierEmail);
      final data = await SupabaseService.getSupplierData(tableName);

      if (data.isEmpty) {
        return SupplierSummary(
          totalAnalyses: 0,
          averageRipeness: 0.0,
          averageShelfLife: 0.0,
          qualityGrade: 'No Data',
        );
      }

      final ripenessScores = data
          .where((item) => item['ripeness_score'] != null)
          .map((item) => (item['ripeness_score'] as num).toDouble())
          .toList();

      final averageRipeness = ripenessScores.isNotEmpty
          ? ripenessScores.reduce((a, b) => a + b) / ripenessScores.length
          : 0.0;

      // Calculate average shelf life from ripeness
      double averageShelfLife = 0.0;
      if (averageRipeness <= 3) {
        averageShelfLife = 1.5;
      } else if (averageRipeness <= 7) {
        averageShelfLife = 4.0;
      } else {
        averageShelfLife = 8.0;
      }

      // Determine quality grade
      String qualityGrade;
      if (averageRipeness >= 7) {
        qualityGrade = 'Excellent';
      } else if (averageRipeness >= 4) {
        qualityGrade = 'Good';
      } else {
        qualityGrade = 'Needs Attention';
      }

      return SupplierSummary(
        totalAnalyses: data.length,
        averageRipeness: averageRipeness,
        averageShelfLife: averageShelfLife,
        qualityGrade: qualityGrade,
      );
    } catch (e) {
      print('Error getting supplier summary: $e');
      return SupplierSummary(
        totalAnalyses: 0,
        averageRipeness: 0.0,
        averageShelfLife: 0.0,
        qualityGrade: 'Error',
      );
    }
  }
}