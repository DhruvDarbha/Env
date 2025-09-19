import 'dart:convert';
import '../models/recipe.dart';

class RecipeDetector {
  /// Detect if a message contains recipe content
  static bool containsRecipe(String content) {
    final lowercaseContent = content.toLowerCase();

    // Recipe keywords and patterns
    final recipeKeywords = [
      'recipe', 'ingredients', 'instructions', 'directions',
      'cook', 'bake', 'prepare', 'serves', 'serving',
      'prep time', 'cooking time', 'total time',
      'tablespoon', 'teaspoon', 'cup', 'ounce', 'pound',
      'tbsp', 'tsp', 'oz', 'lb', 'ml', 'grams',
    ];

    // Recipe structure patterns
    final recipePatterns = [
      RegExp(r'ingredients?:', caseSensitive: false),
      RegExp(r'instructions?:', caseSensitive: false),
      RegExp(r'directions?:', caseSensitive: false),
      RegExp(r'steps?:', caseSensitive: false),
      RegExp(r'\d+\s*(cups?|tbsp|tsp|oz|lb|ml|grams?)', caseSensitive: false),
      RegExp(r'serves?\s*\d+', caseSensitive: false),
      RegExp(r'prep\s*time', caseSensitive: false),
      RegExp(r'cook\s*time', caseSensitive: false),
    ];

    // Check for keyword presence (need at least 2 recipe keywords)
    int keywordCount = 0;
    for (final keyword in recipeKeywords) {
      if (lowercaseContent.contains(keyword)) {
        keywordCount++;
        if (keywordCount >= 2) break;
      }
    }

    // Check for recipe structure patterns
    bool hasRecipePattern = recipePatterns.any((pattern) => pattern.hasMatch(content));

    return keywordCount >= 2 || hasRecipePattern;
  }

  /// Extract recipe information from text
  static Recipe? extractRecipe(String content, String messageId) {
    if (!containsRecipe(content)) return null;

    try {
      // Extract recipe name (look for recipe titles)
      String name = _extractRecipeName(content);

      // Extract ingredients
      List<String> ingredients = _extractIngredients(content);

      // Extract instructions
      List<String> instructions = _extractInstructions(content);

      // Extract timing information
      String prepTime = _extractTime(content, ['prep time', 'preparation time']);
      String cookTime = _extractTime(content, ['cook time', 'cooking time', 'bake time']);

      // Extract serving information
      int servings = _extractServings(content);

      // Only create recipe if we have basic information
      if (name.isEmpty || ingredients.isEmpty) {
        return null;
      }

      return Recipe(
        id: 'recipe_$messageId',
        name: name,
        ingredients: ingredients,
        instructions: instructions.isNotEmpty ? instructions : ['Follow the recipe description provided by AskEnv'],
        prepTimeMinutes: _parseTimeToMinutes(prepTime),
        cookTimeMinutes: _parseTimeToMinutes(cookTime),
        servings: servings > 0 ? servings : 4,
        difficulty: DifficultyLevel.medium,
        category: 'AskEnv Suggestions',
        description: 'Recipe suggested by AskEnv based on your food analysis',
        imageUrl: null,
        tags: ['AskEnv', 'AI-generated'],
      );
    } catch (e) {
      print('Error extracting recipe: $e');
      return null;
    }
  }

  static String _extractRecipeName(String content) {
    // First, look for explicit recipe names in common patterns
    final specificPatterns = [
      // "recipe for X" or "X recipe"
      RegExp(r'recipe for ([A-Z][a-zA-Z\s]+)', caseSensitive: false),
      RegExp(r'([A-Z][a-zA-Z\s]+) recipe', caseSensitive: false),
      // "Here's a simple recipe for X" or similar
      RegExp(r"(?:here's|here is).*?(?:recipe for|for) ([A-Z][a-zA-Z\s]+)", caseSensitive: false),
      // Extract from user questions about specific foods (look back at user input)
      RegExp(r'(?:recipes? for|make|cook|bake) ([A-Z][a-zA-Z\s]+)', caseSensitive: false),
    ];

    for (final pattern in specificPatterns) {
      final matches = pattern.allMatches(content);
      for (final match in matches) {
        if (match.group(1) != null) {
          String name = match.group(1)!.trim();
          name = _cleanRecipeName(name);
          if (_isValidRecipeName(name)) {
            return name;
          }
        }
      }
    }

    // Look for recipe names at the beginning of sentences
    final lines = content.split('\n');
    for (final line in lines.take(5)) { // Check first 5 lines
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Skip common section headers
      if (RegExp(r'^(?:ingredients?|instructions?|directions?|method|preparation|steps?)[:*]?$', caseSensitive: false).hasMatch(trimmed)) {
        continue;
      }

      // Look for capitalized words that could be recipe names
      final namePattern = RegExp(r'^(?:\*\*)?([A-Z][a-zA-Z\s]+?)(?:\*\*)?[:.]?\s*$');
      final match = namePattern.firstMatch(trimmed);
      if (match != null && match.group(1) != null) {
        String name = match.group(1)!.trim();
        name = _cleanRecipeName(name);
        if (_isValidRecipeName(name)) {
          return name;
        }
      }
    }

    return 'AskEnv Recipe Suggestion';
  }

  static String _cleanRecipeName(String name) {
    // Remove common unwanted words and clean up
    name = name.replaceAll(RegExp(r'\b(recipe|dish|meal)\b', caseSensitive: false), '').trim();
    name = name.replaceAll(RegExp(r'[*:]'), '').trim(); // Remove markdown and colons

    // Remove common articles and prepositions at the beginning
    name = name.replaceAll(RegExp(r'^(a|an|the|some|make|try|how about)\s+', caseSensitive: false), '').trim();

    // Capitalize first letter for consistency
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
    }

    return name;
  }

  static bool _isValidRecipeName(String name) {
    if (name.length < 3 || name.length > 50) return false;

    // Reject common section headers and unwanted terms
    final unwantedTerms = [
      'ingredients', 'instructions', 'directions', 'method', 'preparation', 'steps',
      'delicious', 'simple', 'easy', 'great', 'perfect', 'choice'
    ];

    final lowerName = name.toLowerCase();
    for (final term in unwantedTerms) {
      if (lowerName.contains(term)) return false;
    }

    // Don't start with numbers or special characters
    if (RegExp(r'^[\d\W]').hasMatch(name)) return false;

    return true;
  }

  static List<String> _extractIngredients(String content) {
    final ingredients = <String>[];

    // Look for ingredients section
    final ingredientsMatch = RegExp(
      r'ingredients?:?\s*\n?((?:.+\n?)*?)(?:\n\s*(?:instructions?|directions?|steps?):|\n\s*\n|$)',
      caseSensitive: false,
      multiLine: true,
    ).firstMatch(content);

    if (ingredientsMatch != null) {
      final ingredientsText = ingredientsMatch.group(1) ?? '';

      // Split by lines and clean up
      final lines = ingredientsText.split('\n');
      for (final line in lines) {
        final cleaned = line.trim().replaceAll(RegExp(r'^[-•*]\s*'), '');
        if (cleaned.isNotEmpty && cleaned.length > 2) {
          ingredients.add(cleaned);
        }
      }
    } else {
      // Look for measurement patterns throughout the text
      final measurementPattern = RegExp(
        r'(\d+(?:\/\d+)?\s*(?:cups?|tbsp|tsp|tablespoons?|teaspoons?|oz|ounces?|lb|pounds?|ml|grams?|g)\s+[a-zA-Z\s]+)',
        caseSensitive: false,
      );

      final matches = measurementPattern.allMatches(content);
      for (final match in matches) {
        if (match.group(0) != null) {
          ingredients.add(match.group(0)!.trim());
        }
      }
    }

    return ingredients;
  }

  static List<String> _extractInstructions(String content) {
    final instructions = <String>[];

    // Look for instructions section
    final instructionsMatch = RegExp(
      r'(?:instructions?|directions?|steps?):?\s*\n?((?:.+\n?)*?)(?:\n\s*\n|$)',
      caseSensitive: false,
      multiLine: true,
    ).firstMatch(content);

    if (instructionsMatch != null) {
      final instructionsText = instructionsMatch.group(1) ?? '';

      // Split by lines and clean up
      final lines = instructionsText.split('\n');
      for (final line in lines) {
        final cleaned = line.trim().replaceAll(RegExp(r'^[-•*\d+\.]\s*'), '');
        if (cleaned.isNotEmpty && cleaned.length > 5) {
          instructions.add(cleaned);
        }
      }
    }

    return instructions;
  }

  static String _extractTime(String content, List<String> timeKeywords) {
    for (final keyword in timeKeywords) {
      final pattern = RegExp(
        r'$keyword:?\s*(\d+(?:\s*-\s*\d+)?\s*(?:minutes?|mins?|hours?|hrs?))',
        caseSensitive: false,
      );

      final match = pattern.firstMatch(content);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }
    return '';
  }

  static int _extractServings(String content) {
    final servingsPattern = RegExp(
      r'serves?\s*(\d+)|(\d+)\s*servings?',
      caseSensitive: false,
    );

    final match = servingsPattern.firstMatch(content);
    if (match != null) {
      final servingsStr = match.group(1) ?? match.group(2);
      if (servingsStr != null) {
        return int.tryParse(servingsStr) ?? 0;
      }
    }
    return 0;
  }

  static int _parseTimeToMinutes(String timeStr) {
    if (timeStr.isEmpty) return 0;

    final hoursMatch = RegExp(r'(\d+)\s*(?:hours?|hrs?)').firstMatch(timeStr);
    final minutesMatch = RegExp(r'(\d+)\s*(?:minutes?|mins?)').firstMatch(timeStr);

    int totalMinutes = 0;

    if (hoursMatch != null) {
      totalMinutes += (int.tryParse(hoursMatch.group(1) ?? '0') ?? 0) * 60;
    }

    if (minutesMatch != null) {
      totalMinutes += int.tryParse(minutesMatch.group(1) ?? '0') ?? 0;
    }

    return totalMinutes;
  }
}