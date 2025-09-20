import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionService {
  static const String _gcpFunctionUrl = 'https://us-west2-proware-378020.cloudfunctions.net/function-1';

  /// Send user's image directly to GCP function via POST
  static Future<String> predictRipeness(String imagePath, {String? produceType}) async {
    try {
      print('Starting prediction for user image: $imagePath');

      final File imageFile = File(imagePath);

      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist: $imagePath');
      }

      print('📸 Sending image directly to GCP function');
      print('📁 File size: ${await imageFile.length()} bytes');

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_gcpFunctionUrl));
      
      // Add the image file to the request
      request.files.add(
        await http.MultipartFile.fromPath('file', imagePath),
      );
      
      // Add headers to specify image format
      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['Accept'] = 'application/json';

      print('🔗 Sending POST request to: $_gcpFunctionUrl');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📊 GCP Response Status: ${response.statusCode}');
      print('📄 GCP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the response - handle different response formats
        final String responseBody = response.body;

        // If the response is JSON, try to extract the prediction
        if (responseBody.startsWith('{') || responseBody.startsWith('[')) {
          try {
            // Try to parse as JSON and extract prediction
            final Map<String, dynamic> jsonResponse = json.decode(responseBody);
            final String prediction = jsonResponse['prediction'] ??
                                    jsonResponse['result'] ??
                                    jsonResponse['message'] ??
                                    responseBody;
            print('✅ Extracted prediction: $prediction');
            return _formatPredictionResult(prediction, produceType);
          } catch (e) {
            print('⚠️ JSON parsing failed, returning raw response: $responseBody');
            // If JSON parsing fails, return the raw response
            return _formatPredictionResult(responseBody, produceType);
          }
        } else {
          print('📝 Non-JSON response, returning as-is: $responseBody');
          // If it's not JSON, return the raw response
          return _formatPredictionResult(responseBody, produceType);
        }
      } else {
        throw Exception('GCP function returned status code: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error in predictRipeness: $e');
      throw Exception('Failed to predict ripeness: $e');
    }
  }

  /// Format the raw prediction result with ripeness category and consumption days
  static String _formatPredictionResult(String rawPrediction, [String? produceType]) {
    try {
      // Extract the numerical value from the prediction
      final double ripenessValue = double.parse(rawPrediction.trim());
      
      // Determine ripeness category based on the histogram thresholds
      String category;
      int daysUntilBad;
      
      if (ripenessValue < 7.0) {
        // Overripe: < 3 N
        category = 'Overripe';
        daysUntilBad = 1;
      } else if (ripenessValue >= 8.0 && ripenessValue < 15.0) {
        // Ripe: 3 N ≤ x < 7 N
        category = 'Ripe';
        daysUntilBad = _calculateRipeDays(ripenessValue, produceType);
      } else {
        // Unripe: ≥ 7 N
        category = 'Unripe';
        daysUntilBad = _calculateUnripeDays(ripenessValue, produceType);
      }
      
      // Format the result with enhanced information
      return '''Ripeness: ${ripenessValue.toStringAsFixed(2)} Newtons
Category: $category
Days until it goes bad: $daysUntilBad days''';
      
    } catch (e) {
      print('⚠️ Error parsing prediction value: $e');
      // If parsing fails, return the raw prediction with basic formatting
      return 'Ripeness: $rawPrediction Newtons\nCategory: Unable to determine\nDays until it goes bad: Check manually';
    }
  }

  /// Calculate days for overripe produce based on ripeness value and produce type
  static int _calculateOverripeDays(double ripenessValue, String? produceType) {
    // Overripe: 0-3 Newtons
    // More overripe = fewer days
    int baseDays;
    if (ripenessValue < 1.0) {
      baseDays = 1; // Very overripe - 1 day
    } else if (ripenessValue < 2.0) {
      baseDays = 1; // Overripe - 1 day
    } else {
      baseDays = 2; // Slightly overripe - 2 days
    }
    
    // Adjust based on produce type
    return _adjustDaysForProduceType(baseDays, produceType, isOverripe: true);
  }

  /// Calculate days for ripe produce based on ripeness value and produce type
  static int _calculateRipeDays(double ripenessValue, String? produceType) {
    // Ripe: 3-7 Newtons
    // Optimal ripeness range with varying shelf life
    int baseDays;
    if (ripenessValue >= 3.0 && ripenessValue < 4.0) {
      baseDays = 2; // Just ripe - 2 days
    } else if (ripenessValue >= 4.0 && ripenessValue < 5.0) {
      baseDays = 3; // Perfectly ripe - 3 days
    } else if (ripenessValue >= 5.0 && ripenessValue < 6.0) {
      baseDays = 4; // Still ripe - 4 days
    } else {
      baseDays = 3; // 6-7 N - 3 days (getting less ripe)
    }
    
    // Adjust based on produce type
    return _adjustDaysForProduceType(baseDays, produceType, isOverripe: false);
  }

  /// Calculate days for unripe produce based on ripeness value and produce type
  static int _calculateUnripeDays(double ripenessValue, String? produceType) {
    // Unripe: 7+ Newtons
    // More unripe = more days until consumption
    int baseDays;
    if (ripenessValue >= 7.0 && ripenessValue < 8.0) {
      baseDays = 5; // Slightly unripe - 5 days
    } else if (ripenessValue >= 8.0 && ripenessValue < 9.0) {
      baseDays = 6; // Unripe - 6 days
    } else if (ripenessValue >= 9.0 && ripenessValue < 10.0) {
      baseDays = 7; // Very unripe - 7 days
    } else if (ripenessValue >= 10.0 && ripenessValue < 12.0) {
      baseDays = 8; // Quite unripe - 8 days
    } else {
      baseDays = 9; // Very unripe (12+ N) - 9+ days
    }
    
    // Adjust based on produce type
    return _adjustDaysForProduceType(baseDays, produceType, isOverripe: false);
  }

  /// Adjust days based on produce type characteristics
  static int _adjustDaysForProduceType(int baseDays, String? produceType, {required bool isOverripe}) {
    if (produceType == null) return baseDays;
    
    final type = produceType.toLowerCase();
    
    // Fast-ripening fruits (banana, avocado, pear)
    if (type.contains('banana') || type.contains('avocado') || type.contains('pear')) {
      return isOverripe ? baseDays : (baseDays + 1); // Bananas ripen quickly
    }
    
    // Medium-ripening fruits (apple, orange, peach)
    if (type.contains('apple') || type.contains('orange') || type.contains('peach') || 
        type.contains('plum') || type.contains('nectarine')) {
      return baseDays; // Standard shelf life
    }
    
    // Slow-ripening fruits (citrus, pomegranate)
    if (type.contains('lemon') || type.contains('lime') || type.contains('grapefruit') || 
        type.contains('pomegranate') || type.contains('kiwi')) {
      return isOverripe ? baseDays : (baseDays + 2); // Citrus lasts longer
    }
    
    // Berries (strawberry, blueberry, raspberry)
    if (type.contains('berry') || type.contains('strawberry') || type.contains('blueberry') || 
        type.contains('raspberry') || type.contains('blackberry')) {
      return isOverripe ? (baseDays - 1).clamp(1, 3) : baseDays; // Berries spoil quickly
    }
    
    // Stone fruits (cherry, apricot)
    if (type.contains('cherry') || type.contains('apricot')) {
      return isOverripe ? (baseDays - 1).clamp(1, 3) : (baseDays + 1);
    }
    
    // Default adjustment
    return baseDays;
  }
}
