import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_config.dart';

class GeminiVisionService {
  static GenerativeModel? _model;

  /// Initialize the Gemini model
  static GenerativeModel _getModel() {
    if (_model == null) {
      if (!ApiConfig.isGeminiApiKeyConfigured) {
        throw Exception('Gemini API key not configured');
      }
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: ApiConfig.geminiApiKey,
      );
    }
    return _model!;
  }

  /// Analyze fruit image for brand detection
  static Future<String?> detectFruitBrand(String imagePath) async {
    try {
      if (!ApiConfig.isGeminiApiKeyConfigured) {
        print('Gemini API key not configured, skipping brand detection');
        return null;
      }

      final model = _getModel();

      // Read image file
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Image file not found: $imagePath');
      }

      final imageBytes = await imageFile.readAsBytes();

      // Create the prompt for brand detection
      final prompt = _buildBrandDetectionPrompt();

      // Create content with image and text
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      // Generate response
      final response = await model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        print('Gemini returned empty response for brand detection');
        return null;
      }

      // Parse the response to extract brand name
      final brandName = _parseBrandResponse(response.text!);

      print('Gemini brand detection result: "$brandName"');
      return brandName;

    } catch (e) {
      print('Error in Gemini brand detection: $e');
      return null;
    }
  }

  /// Build optimized prompt for brand detection
  static String _buildBrandDetectionPrompt() {
    return '''
Analyze this fruit/produce image and identify ONLY the brand name if visible.

Look carefully for:
- Small stickers on the fruit with brand names (Dole, Chiquita, Del Monte, Driscoll's, Halos, etc.)
- Company logos on packaging or labels
- Any text indicating the supplier or brand name
- PLU stickers with brand identifiers

IMPORTANT:
- Return ONLY the brand name if clearly visible
- If no brand is detected, return "none"
- Be conservative - only return a brand if you're confident
- Do not make assumptions or guesses

Examples of good responses:
- "Dole"
- "Chiquita"
- "Del Monte"
- "Driscoll's"
- "Halos"
- "none"

Response:''';
  }

  /// Parse Gemini response to extract clean brand name
  static String? _parseBrandResponse(String response) {
    // Clean up the response
    final cleaned = response.trim().toLowerCase();

    // If response indicates no brand found
    if (cleaned.contains('none') ||
        cleaned.contains('no brand') ||
        cleaned.contains('not found') ||
        cleaned.contains('unable to') ||
        cleaned.isEmpty) {
      return null;
    }

    // Extract potential brand names
    final commonBrands = [
      'dole',
      'chiquita',
      'del monte',
      'driscoll\'s',
      'driscolls',
      'stemilt',
      'wonderful',
      'zespri',
      'sunkist',
      'organic girl',
      'earthbound',
      'fresh express',
      'mann\'s',
      'manns',
      'andy boy',
      'ocean mist',
      'tanimura & antle',
      'green giant',
      'birds eye',
      'pure pacific',
      'paramount',
      'naturipe',
      'wish farms',
      'halos'
    ];

    // Check if response contains a known brand
    for (final brand in commonBrands) {
      if (cleaned.contains(brand)) {
        // Return properly capitalized version
        return _capitalizeProperName(brand);
      }
    }

    // If response looks like a brand name (single word or short phrase)
    if (cleaned.length > 2 && cleaned.length < 20 && !cleaned.contains(' ')) {
      return _capitalizeProperName(cleaned);
    }

    // Otherwise, no clear brand detected
    return null;
  }

  /// Capitalize brand names properly
  static String _capitalizeProperName(String name) {
    switch (name.toLowerCase()) {
      case 'dole':
        return 'Dole';
      case 'chiquita':
        return 'Chiquita';
      case 'del monte':
        return 'Del Monte';
      case 'driscoll\'s':
      case 'driscolls':
        return 'Driscoll\'s';
      case 'stemilt':
        return 'Stemilt';
      case 'wonderful':
        return 'Wonderful';
      case 'zespri':
        return 'Zespri';
      case 'sunkist':
        return 'Sunkist';
      case 'organic girl':
        return 'Organic Girl';
      case 'earthbound':
        return 'Earthbound';
      case 'fresh express':
        return 'Fresh Express';
      case 'mann\'s':
      case 'manns':
        return 'Mann\'s';
      case 'andy boy':
        return 'Andy Boy';
      case 'ocean mist':
        return 'Ocean Mist';
      case 'tanimura & antle':
        return 'Tanimura & Antle';
      case 'green giant':
        return 'Green Giant';
      case 'birds eye':
        return 'Birds Eye';
      case 'pure pacific':
        return 'Pure Pacific';
      case 'paramount':
        return 'Paramount';
      case 'naturipe':
        return 'NatureSweet';
      case 'wish farms':
        return 'Wish Farms';
      case 'halos':
        return 'Halos';
      default:
        // Capitalize first letter for unknown brands
        return name[0].toUpperCase() + name.substring(1).toLowerCase();
    }
  }
}