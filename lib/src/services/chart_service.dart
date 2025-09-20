import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChartService {
  static const String baseUrl = 'http://localhost:5001';

  /// Get ripeness chart image as bytes
  static Future<Uint8List?> getRipenessChart(String supplierEmail) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/generate_ripeness_chart/$supplierEmail'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Error getting ripeness chart: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching ripeness chart: $e');
      return null;
    }
  }

  /// Get shelf life chart image as bytes
  static Future<Uint8List?> getShelfLifeChart(String supplierEmail) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/generate_shelf_life_chart/$supplierEmail'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Error getting shelf life chart: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching shelf life chart: $e');
      return null;
    }
  }

  /// Get supplier summary statistics
  static Future<Map<String, dynamic>?> getSupplierSummary(String supplierEmail) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/supplier_summary/$supplierEmail'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error getting supplier summary: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching supplier summary: $e');
      return null;
    }
  }

  /// Check if chart service is available
  static Future<bool> isServiceAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Chart service not available: $e');
      return false;
    }
  }
}