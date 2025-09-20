import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionService {
  static const String _gcpFunctionUrl = 'https://us-west2-proware-378020.cloudfunctions.net/function-1';

  /// Send user's image directly to GCP function via POST
  static Future<String> predictRipeness(String imagePath) async {
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
            return _formatPredictionResult(prediction);
          } catch (e) {
            print('⚠️ JSON parsing failed, returning raw response: $responseBody');
            // If JSON parsing fails, return the raw response
            return _formatPredictionResult(responseBody);
          }
        } else {
          print('📝 Non-JSON response, returning as-is: $responseBody');
          // If it's not JSON, return the raw response
          return _formatPredictionResult(responseBody);
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
  static String _formatPredictionResult(String rawPrediction) {
    try {
      // Extract the numerical value from the prediction
      final double ripenessValue = double.parse(rawPrediction.trim());
      
      // Determine ripeness category based on the histogram thresholds
      String category;
      int daysUntilBad;
      
      if (ripenessValue < 3.0) {
        // Overripe: < 8 N
        category = 'Overripe';
        daysUntilBad = 1; // 1 day left to consume
      } else if (ripenessValue >= 3.0 && ripenessValue < 7.0) {
        // Ripe: 8 N ≤ x < 22 N
        category = 'Ripe';
        daysUntilBad = 3; // 3-4 days left to consume
      } else {
        // Unripe: ≥ 22 N
        category = 'Unripe';
        daysUntilBad = 5; // 5-6 days left to consume
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
}
