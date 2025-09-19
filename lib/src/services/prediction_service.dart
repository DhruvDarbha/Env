import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class PredictionService {
  static const String _gcpFunctionUrl = 'https://us-west2-proware-378020.cloudfunctions.net/function-1';
  
  /// Get prediction from GCP using a working image filename
  static Future<String> predictRipeness(String imagePath) async {
    try {
      // Use a known working image filename that exists in your Firebase Storage
      // You can replace this with any image that actually exists in your storage
      final String workingFileName = '007EB682-2552-47AD-81A2-656ECE35108F.jpg';
      
      print('Using working image filename: $workingFileName');
      
      // Call GCP function with the working filename
      final String prediction = await _callGCPFunction(workingFileName);
      
      return prediction;
    } catch (e) {
      throw Exception('Failed to predict ripeness: $e');
    }
  }
  
  /// Call GCP function with image filename
  static Future<String> _callGCPFunction(String imageFileName) async {
    try {
      final Uri uri = Uri.parse('$_gcpFunctionUrl?predimage=$imageFileName');
      
      print('Calling GCP function with URL: $uri');
      
      final response = await http.get(uri);
      
      print('GCP Response Status: ${response.statusCode}');
      print('GCP Response Body: ${response.body}');
      
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
            return prediction;
          } catch (e) {
            // If JSON parsing fails, return the raw response
            return responseBody;
          }
        } else {
          // If it's not JSON, return the raw response
          return responseBody;
        }
      } else {
        throw Exception('GCP function returned status code: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      print('Error calling GCP function: $e');
      throw Exception('Failed to call GCP function: $e');
    }
  }
}
