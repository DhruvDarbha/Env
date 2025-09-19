import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../models/produce_analysis.dart';
import '../models/recipe.dart';
import '../models/food_bank.dart';
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'https://api.freshtrack.com';
  static const Duration timeout = Duration(seconds: 30);

  // Authentication
  static Future<bool> loginSupplier(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication logic
    return email == 'supplier@freshtrack.com' && password == 'demo123';
  }

  static Future<bool> loginConsumer(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication logic
    return email == 'james@savr.com' && password == 'demo123';
  }

  // Produce Analysis
  static Future<ProduceAnalysis> analyzeProduceImage(String imagePath) async {
    // Simulate AI analysis delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock analysis
    return ProduceAnalysis.mockAppleAnalysis;
  }

  // Recipes
  static Future<List<Recipe>> searchRecipes(String query) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return filtered mock recipes
    final recipes = Recipe.mockRecipes;
    if (query.isEmpty) return recipes;

    return recipes.where((recipe) =>
      recipe.name.toLowerCase().contains(query.toLowerCase()) ||
      recipe.ingredients.any((ingredient) =>
        ingredient.toLowerCase().contains(query.toLowerCase())
      )
    ).toList();
  }

  // Food Banks
  static Future<List<FoodBank>> searchFoodBanks(String zipCode) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return mock food banks
    return FoodBank.mockFoodBanks;
  }

  // Chat
  static Future<Message> sendChatMessage(String message) async {
    // Simulate AI response delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate mock response based on input
    String response = _generateChatResponse(message);

    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
    );
  }

  static String _generateChatResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('quality') || message.contains('fresh')) {
      return "I understand you're asking about produce quality. Based on your question, I'd recommend checking the ripeness indicators and storage conditions. Would you like me to analyze a photo of your produce?";
    } else if (message.contains('recipe') || message.contains('cook')) {
      return "I can help you find recipes based on your available produce! What ingredients do you have on hand? I can suggest some delicious and nutritious recipes.";
    } else if (message.contains('food bank') || message.contains('donate')) {
      return "I can help you find local food banks in your area. If you have surplus produce to donate, I can connect you with organizations that would appreciate fresh donations.";
    } else if (message.contains('storage') || message.contains('store')) {
      return "Proper storage is key to maintaining produce quality! Different fruits and vegetables have specific storage requirements. Would you like storage tips for a particular type of produce?";
    } else {
      return "I'm here to help with all your produce-related questions! I can assist with quality analysis, recipe suggestions, storage tips, and connecting you with local food resources. What would you like to know?";
    }
  }

  // Generic HTTP methods for future API integration
  static Future<http.Response> _get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.get(uri).timeout(timeout);
  }

  static Future<http.Response> _post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ).timeout(timeout);
  }
}