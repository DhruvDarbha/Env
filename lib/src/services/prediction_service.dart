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
            return prediction;
          } catch (e) {
            print('⚠️ JSON parsing failed, returning raw response: $responseBody');
            // If JSON parsing fails, return the raw response
            return responseBody;
          }
        } else {
          print('📝 Non-JSON response, returning as-is: $responseBody');
          // If it's not JSON, return the raw response
          return responseBody;
        }
      } else {
        throw Exception('GCP function returned status code: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error in predictRipeness: $e');
      throw Exception('Failed to predict ripeness: $e');
    }
  }
}
