import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class RecipeStorageService {
  static const String _savedRecipesKey = 'saved_recipes';

  /// Save a recipe to local storage
  static Future<bool> saveRecipe(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRecipes = await getSavedRecipes();

      // Check if recipe already exists (by ID)
      final existingIndex = savedRecipes.indexWhere((r) => r.id == recipe.id);

      if (existingIndex >= 0) {
        // Update existing recipe
        savedRecipes[existingIndex] = recipe;
      } else {
        // Add new recipe
        savedRecipes.add(recipe);
      }

      // Convert to JSON and save
      final recipesJson = savedRecipes.map((r) => r.toJson()).toList();
      await prefs.setString(_savedRecipesKey, jsonEncode(recipesJson));

      print('Recipe saved: ${recipe.name}');
      return true;
    } catch (e) {
      print('Error saving recipe: $e');
      return false;
    }
  }

  /// Get all saved recipes
  static Future<List<Recipe>> getSavedRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJsonString = prefs.getString(_savedRecipesKey);

      if (recipesJsonString == null || recipesJsonString.isEmpty) {
        return [];
      }

      final recipesJson = jsonDecode(recipesJsonString) as List<dynamic>;
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      print('Error loading saved recipes: $e');
      return [];
    }
  }

  /// Remove a recipe from saved recipes
  static Future<bool> removeRecipe(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRecipes = await getSavedRecipes();

      savedRecipes.removeWhere((recipe) => recipe.id == recipeId);

      final recipesJson = savedRecipes.map((r) => r.toJson()).toList();
      await prefs.setString(_savedRecipesKey, jsonEncode(recipesJson));

      print('Recipe removed: $recipeId');
      return true;
    } catch (e) {
      print('Error removing recipe: $e');
      return false;
    }
  }

  /// Check if a recipe is already saved
  static Future<bool> isRecipeSaved(String recipeId) async {
    final savedRecipes = await getSavedRecipes();
    return savedRecipes.any((recipe) => recipe.id == recipeId);
  }

  /// Get a specific saved recipe by ID
  static Future<Recipe?> getSavedRecipe(String recipeId) async {
    final savedRecipes = await getSavedRecipes();
    try {
      return savedRecipes.firstWhere((recipe) => recipe.id == recipeId);
    } catch (e) {
      return null;
    }
  }

  /// Clear all saved recipes
  static Future<bool> clearAllRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedRecipesKey);
      print('All saved recipes cleared');
      return true;
    } catch (e) {
      print('Error clearing recipes: $e');
      return false;
    }
  }

  /// Get recipes by category
  static Future<List<Recipe>> getRecipesByCategory(String category) async {
    final savedRecipes = await getSavedRecipes();
    return savedRecipes.where((recipe) => recipe.category == category).toList();
  }

  /// Search saved recipes
  static Future<List<Recipe>> searchRecipes(String query) async {
    final savedRecipes = await getSavedRecipes();
    final lowercaseQuery = query.toLowerCase();

    return savedRecipes.where((recipe) {
      return recipe.name.toLowerCase().contains(lowercaseQuery) ||
             recipe.description.toLowerCase().contains(lowercaseQuery) ||
             recipe.ingredients.any((ingredient) =>
                 ingredient.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Get recipe statistics
  static Future<Map<String, int>> getRecipeStats() async {
    final savedRecipes = await getSavedRecipes();

    final stats = <String, int>{};
    stats['total'] = savedRecipes.length;
    stats['askenv_recipes'] = savedRecipes
        .where((recipe) => recipe.category == 'AskEnv Suggestions')
        .length;

    // Count by difficulty
    for (final recipe in savedRecipes) {
      final key = '${recipe.difficulty.toString().split('.').last.toLowerCase()}_difficulty';
      stats[key] = (stats[key] ?? 0) + 1;
    }

    return stats;
  }
}