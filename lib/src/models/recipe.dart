enum DifficultyLevel { easy, medium, hard }

class Recipe {
  final String id;
  final String name;
  final String description;
  final int cookTimeMinutes;
  final DifficultyLevel difficulty;
  final List<String> ingredients;
  final List<String> instructions;
  final String? imageUrl;
  final List<String> tags;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
    this.imageUrl,
    required this.tags,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      cookTimeMinutes: json['cookTimeMinutes'],
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
      ),
      ingredients: List<String>.from(json['ingredients']),
      instructions: List<String>.from(json['instructions']),
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cookTimeMinutes': cookTimeMinutes,
      'difficulty': difficulty.toString().split('.').last,
      'ingredients': ingredients,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'tags': tags,
    };
  }

  String get difficultyString {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  // Mock recipes for demo
  static List<Recipe> get mockRecipes => [
    Recipe(
      id: 'recipe_001',
      name: 'Fresh Garden Salad',
      description: 'A refreshing mix of seasonal vegetables',
      cookTimeMinutes: 15,
      difficulty: DifficultyLevel.easy,
      ingredients: ['Lettuce', 'Tomatoes', 'Cucumbers', 'Olive oil', 'Vinegar'],
      instructions: ['Wash vegetables', 'Chop into bite-sized pieces', 'Mix with dressing'],
      tags: ['healthy', 'vegetarian', 'quick'],
    ),
    Recipe(
      id: 'recipe_002',
      name: 'Roasted Vegetable Medley',
      description: 'Perfectly roasted seasonal vegetables',
      cookTimeMinutes: 45,
      difficulty: DifficultyLevel.medium,
      ingredients: ['Mixed vegetables', 'Herbs', 'Olive oil', 'Salt', 'Pepper'],
      instructions: ['Preheat oven', 'Cut vegetables', 'Season and roast'],
      tags: ['healthy', 'vegetarian', 'roasted'],
    ),
    Recipe(
      id: 'recipe_003',
      name: 'Green Smoothie Bowl',
      description: 'Nutritious smoothie bowl with fresh toppings',
      cookTimeMinutes: 10,
      difficulty: DifficultyLevel.easy,
      ingredients: ['Spinach', 'Banana', 'Berries', 'Yogurt', 'Granola'],
      instructions: ['Blend fruits and spinach', 'Pour into bowl', 'Add toppings'],
      tags: ['healthy', 'breakfast', 'smoothie'],
    ),
  ];
}