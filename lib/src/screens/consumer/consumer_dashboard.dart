import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/background_wrapper.dart';
import '../../widgets/food_bank_map.dart';
import '../../widgets/zipcode_search.dart';
import '../../models/food_bank.dart';
import '../../models/recipe.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/recipe_storage_service.dart';

class ConsumerDashboard extends StatefulWidget {
  const ConsumerDashboard({super.key});

  @override
  State<ConsumerDashboard> createState() => _ConsumerDashboardState();
}

class _ConsumerDashboardState extends State<ConsumerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  String? _latestPrediction;

  // Food bank map state
  String? _searchZipCode;
  Position? _userLocation;
  bool _isLoadingMap = false;

  // Image analysis state
  String? _lastAnalyzedImagePath;

  // Recipes state
  List<Recipe>? _savedRecipes;
  bool _isLoadingRecipes = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedRecipes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hi James!'),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Photo Analysis'),
            Tab(text: 'Recipes'),
            Tab(text: 'Food Banks'),
          ],
        ),
      ),
      body: BackgroundWrapper(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPhotoAnalysisTab(),
            _buildRecipesTab(),
            _buildFoodBanksTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
          // Camera Options at the top
          Column(
            children: [
              // Camera Button
              _buildActionButton(
                icon: Icons.camera_alt,
                title: 'Take Photo',
                subtitle: 'Use camera to capture food',
                onTap: _openCamera,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              // Gallery Button
              _buildActionButton(
                icon: Icons.photo_library,
                title: 'Choose from Gallery',
                subtitle: 'Select existing photo',
                onTap: _pickFromGallery,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              // AI Chat Button
              _buildActionButton(
                icon: Icons.eco,
                title: 'Ask AskEnv',
                subtitle: 'Chat with our environmental AI assistant',
                onTap: _openAskEnvChat,
                color: Colors.teal,
              ),

              const SizedBox(height: 32),

              // Tips Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Photography Tips',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• Ensure good lighting'),
                    Text('• Place food on clean surface'),
                    Text('• Capture from multiple angles'),
                    Text('• Focus on any damaged areas'),
                  ],
                ),
              ),
            ],
          ),

          // Add some space before prediction result
          const SizedBox(height: 24),

          // Prediction Result Display (if available)
          if (_latestPrediction != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Latest Analysis Result',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _latestPrediction!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }

  Future<void> _openCamera() async {
    final Map<String, dynamic>? result = await context.push<Map<String, dynamic>>('/camera');
    if (result != null) {
      setState(() {
        _latestPrediction = result['prediction'] as String?;
        _lastAnalyzedImagePath = result['imagePath'] as String?;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        // Navigate to analysis screen with the image and wait for result
        final String? prediction = await context.push<String>('/photo-analysis', extra: image.path);
        if (prediction != null) {
          setState(() {
            _latestPrediction = prediction;
            _lastAnalyzedImagePath = image.path;
          });
        }
      }
    } catch (e) {
      print('Error picking from gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error accessing gallery')),
      );
    }
  }

  void _openAskEnvChat() {
    // Navigate to AskEnv chat with context if available
    context.push('/askenv-chat', extra: {
      'imageContext': _latestPrediction,
      'imagePath': _lastAnalyzedImagePath,
    }).then((_) {
      // Refresh recipes when returning from chat in case new recipes were saved
      _loadSavedRecipes();
    });
  }

  Future<void> _loadSavedRecipes() async {
    setState(() {
      _isLoadingRecipes = true;
    });

    try {
      final recipes = await RecipeStorageService.getSavedRecipes();
      setState(() {
        _savedRecipes = recipes;
        _isLoadingRecipes = false;
      });
      print('Loaded ${recipes.length} saved recipes');
    } catch (e) {
      print('Error loading saved recipes: $e');
      setState(() {
        _savedRecipes = [];
        _isLoadingRecipes = false;
      });
    }
  }

  Widget _buildRecipesTab() {
    if (_isLoadingRecipes) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final savedRecipes = _savedRecipes ?? [];

        if (savedRecipes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Saved Recipes Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ask AskEnv for recipe suggestions and save them here!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _openAskEnvChat,
                    icon: const Icon(Icons.eco),
                    label: const Text('Ask AskEnv for Recipes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: savedRecipes.length,
      itemBuilder: (context, index) {
        final recipe = savedRecipes[index];
        return _buildRecipeCard(recipe);
      },
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showRecipeDetails(recipe),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and category
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (recipe.category.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              recipe.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteRecipe(recipe),
                    icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
                  ),
                ],
              ),

              // Recipe info
              const SizedBox(height: 12),
              Row(
                children: [
                  if (recipe.servings > 0) ...[
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.servings} servings',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (recipe.ingredients.isNotEmpty) ...[
                    Icon(Icons.list, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.ingredients.length} ingredients',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ],
              ),

              // Description preview
              if (recipe.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  recipe.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showRecipeDetails(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recipe name and info
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (recipe.servings > 0) ...[
                        Icon(Icons.people, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${recipe.servings} servings'),
                        const SizedBox(width: 16),
                      ],
                      Icon(Icons.schedule, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${recipe.prepTimeMinutes + recipe.cookTimeMinutes} min'),
                    ],
                  ),

                  // Description
                  if (recipe.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      recipe.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],

                  // Ingredients
                  if (recipe.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...recipe.ingredients.map((ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 8, right: 12),
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: const TextStyle(fontSize: 16, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],

                  // Instructions
                  if (recipe.instructions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...recipe.instructions.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final instruction = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.green[600],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$index',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                instruction,
                                style: const TextStyle(fontSize: 16, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${recipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await RecipeStorageService.removeRecipe(recipe.id);
      _loadSavedRecipes(); // Refresh the recipes list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recipe "${recipe.name}" deleted'),
          backgroundColor: Colors.grey[600],
        ),
      );
    }
  }

  Widget _buildFoodBanksTab() {
    return Column(
      children: [
        // Search section
        Padding(
          padding: const EdgeInsets.all(16),
          child: ZipCodeSearch(
            onSearch: _searchFoodBanksByZipCode,
            onUseCurrentLocation: _useCurrentLocation,
            isLoading: _isLoadingMap,
            initialZipCode: _searchZipCode,
          ),
        ),

        // Map section
        Expanded(
          child: _searchZipCode != null || _userLocation != null
              ? FoodBankMap(
                  zipCode: _searchZipCode,
                  userLocation: _userLocation,
                  onFoodBankSelected: _onFoodBankSelected,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enter a ZIP code or use your current location',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'to find nearby food banks',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  void _searchFoodBanksByZipCode(String zipCode) {
    setState(() {
      _searchZipCode = zipCode;
      _userLocation = null; // Clear user location when searching by zip
      _isLoadingMap = true;
    });

    // The FoodBankMap will handle the loading state
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isLoadingMap = false;
      });
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoadingMap = true;
    });

    try {
      final position = await ApiService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _userLocation = position;
          _searchZipCode = null; // Clear zip code when using current location
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to get current location. Please check your location settings.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoadingMap = false;
      });
    }
  }

  void _onFoodBankSelected(FoodBank foodBank) {
    // Optional: Handle when a food bank is selected from the map
    // Could show additional details, save to favorites, etc.
    print('Selected food bank: ${foodBank.name}');
  }
}