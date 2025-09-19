import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/recipe.dart';
import '../utils/recipe_detector.dart';

class CerebrasService {
  static const String baseUrl = 'https://api.cerebras.ai/v1';
  static const String apiKey = 'csk-3mjtfmjvhcvthf6epne8dfm8f4h95rp5vpnrfff4x48p423r';
  static const String model = 'llama-3.3-70b';
  static const Duration timeout = Duration(seconds: 30);

  /// Send a chat message to AskEnv (Cerebras AI) with optional image context
  static Future<Message> sendChatMessage({
    required String userMessage,
    String? imageContext,
    String? imagePath,
    List<Message> previousMessages = const [],
  }) async {
    try {
      // Build the conversation history
      final messages = _buildMessageHistory(
        userMessage: userMessage,
        imageContext: imageContext,
        previousMessages: previousMessages,
      );

      final response = await _makeApiRequest(messages);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // Generate message ID
        final messageId = DateTime.now().millisecondsSinceEpoch.toString();

        // Detect if the response contains a recipe using AI analysis
        Recipe? detectedRecipe;
        final recipeAnalysis = await analyzeForRecipe(content, userMessage);

        if (recipeAnalysis != null && recipeAnalysis['hasRecipe'] == true) {
          try {
            // Create recipe from AI analysis
            detectedRecipe = Recipe(
              id: 'recipe_$messageId',
              name: recipeAnalysis['recipeName'] ?? 'AskEnv Recipe Suggestion',
              description: 'Recipe suggested by AskEnv based on your request',
              ingredients: List<String>.from(recipeAnalysis['ingredients'] ?? []),
              instructions: List<String>.from(recipeAnalysis['instructions'] ?? []),
              prepTimeMinutes: recipeAnalysis['prepTimeMinutes'] ?? 15,
              cookTimeMinutes: recipeAnalysis['cookTimeMinutes'] ?? 30,
              servings: recipeAnalysis['servings'] ?? 4,
              difficulty: _parseDifficulty(recipeAnalysis['difficulty']),
              category: 'AskEnv Suggestions',
              imageUrl: null,
              tags: ['AskEnv', 'AI-generated'],
            );
            print('Recipe detected by AI: ${detectedRecipe.name}');
          } catch (e) {
            print('Error creating recipe from AI analysis: $e');
          }
        }

        return Message(
          id: messageId,
          content: content,
          sender: MessageSender.bot,
          timestamp: DateTime.now(),
          senderName: 'AskEnv',
          detectedRecipe: detectedRecipe,
        );
      } else {
        print('Cerebras API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('API request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error calling Cerebras API: $e');

      // Return fallback response
      return Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'I apologize, but I\'m experiencing technical difficulties. Please try again in a moment.',
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
        senderName: 'AskEnv',
      );
    }
  }

  /// Build message history for the API request
  static List<Map<String, String>> _buildMessageHistory({
    required String userMessage,
    String? imageContext,
    List<Message> previousMessages = const [],
  }) {
    final messages = <Map<String, String>>[];

    // System message to establish AskEnv's role
    messages.add({
      'role': 'system',
      'content': '''You are AskEnv, a knowledgeable AI assistant specialized in environmental sustainability, food analysis, and waste reduction. You help users with:

1. Food quality assessment and freshness analysis
2. Produce storage and preservation tips
3. Recipe suggestions based on available ingredients
4. Food waste reduction strategies
5. Environmental impact of food choices
6. Sustainable eating practices

Be helpful, friendly, and provide practical advice. Keep responses concise but informative.'''
    });

    // Add previous conversation context (limit to last 6 messages for context)
    final recentMessages = previousMessages.length > 6
        ? previousMessages.sublist(previousMessages.length - 6)
        : previousMessages;

    for (final msg in recentMessages) {
      messages.add({
        'role': msg.sender == MessageSender.user ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

    // Add current user message with image context if available
    String finalUserMessage = userMessage;
    if (imageContext != null && imageContext.isNotEmpty) {
      finalUserMessage = '''Based on this food analysis: "$imageContext"

User question: $userMessage''';
    }

    messages.add({
      'role': 'user',
      'content': finalUserMessage,
    });

    return messages;
  }

  /// Make the actual API request to Cerebras
  static Future<http.Response> _makeApiRequest(List<Map<String, String>> messages) async {
    final uri = Uri.parse('$baseUrl/chat/completions');

    final requestBody = {
      'model': model,
      'messages': messages,
      'stream': false,
      'temperature': 0.7,
      'max_completion_tokens': 500,
    };

    print('Cerebras API Request:');
    print('URL: $uri');
    print('Model: $model');
    print('Messages: ${jsonEncode(messages)}');
    print('Request Body: ${jsonEncode(requestBody)}');

    return await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(requestBody),
    ).timeout(timeout);
  }

  /// Parse difficulty string to DifficultyLevel enum
  static DifficultyLevel _parseDifficulty(String? difficulty) {
    if (difficulty == null) return DifficultyLevel.medium;

    switch (difficulty.toLowerCase()) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'hard':
        return DifficultyLevel.hard;
      default:
        return DifficultyLevel.medium;
    }
  }

  /// Generate contextual response based on image analysis
  static String generateImageContext(String? predictionResult, String? imagePath) {
    if (predictionResult == null || predictionResult.isEmpty) {
      return '';
    }

    return 'The user just analyzed food with these results: $predictionResult';
  }

  /// Validate if the service is properly configured
  static bool isConfigured() {
    return apiKey.isNotEmpty && apiKey != 'YOUR_API_KEY_HERE';
  }

  /// Analyze content using AI to detect and extract recipe information
  static Future<Map<String, dynamic>?> analyzeForRecipe(String content, String userMessage) async {
    try {
      final analysisPrompt = '''Analyze this conversation and determine if it contains a recipe. Return ONLY a JSON response with no additional text.

User asked: "$userMessage"
AI response: "$content"

If this contains a recipe, return:
{
  "hasRecipe": true,
  "recipeName": "Recipe Name Here (just the food name, no articles like 'a', 'an', 'the')",
  "ingredients": ["ingredient 1", "ingredient 2", ...],
  "instructions": ["step 1", "step 2", ...],
  "prepTimeMinutes": 15,
  "cookTimeMinutes": 30,
  "servings": 4,
  "difficulty": "easy" | "medium" | "hard"
}

If this does NOT contain a recipe, return:
{
  "hasRecipe": false
}

Recipe name should be clean (e.g., "Apple Turnovers", "Green Mango Salad", not "a Green Mango Salad").''';

      final messages = [
        {'role': 'user', 'content': analysisPrompt}
      ];

      final response = await _makeApiRequest(messages);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final analysisResult = data['choices'][0]['message']['content'] as String;

        print('Recipe analysis result: $analysisResult');

        // Parse the JSON response
        try {
          // Clean up the response - remove markdown code blocks if present
          String cleanedResult = analysisResult.trim();
          if (cleanedResult.startsWith('```json')) {
            cleanedResult = cleanedResult.substring(7);
          }
          if (cleanedResult.startsWith('```')) {
            cleanedResult = cleanedResult.substring(3);
          }
          if (cleanedResult.endsWith('```')) {
            cleanedResult = cleanedResult.substring(0, cleanedResult.length - 3);
          }
          cleanedResult = cleanedResult.trim();

          final jsonResult = jsonDecode(cleanedResult);
          return jsonResult;
        } catch (e) {
          print('Error parsing recipe analysis JSON: $e');
          print('Raw response: $analysisResult');
          return null;
        }
      }
    } catch (e) {
      print('Error in AI recipe analysis: $e');
    }

    return null;
  }

  /// Get available models (for future expansion)
  static Future<List<String>> getAvailableModels() async {
    try {
      final uri = Uri.parse('$baseUrl/models');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['data'] as List;
        return models.map((model) => model['id'] as String).toList();
      }
    } catch (e) {
      print('Error fetching models: $e');
    }

    return [model]; // Return default model
  }
}