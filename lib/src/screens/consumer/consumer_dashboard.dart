import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/background_wrapper_light.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Photo Analysis'),
            Tab(text: 'Recipes'),
            Tab(text: 'Food Banks'),
            Tab(text: 'Track'),
          ],
        ),
      ),
      body: BackgroundWrapperLight(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPhotoAnalysisTab(),
            _buildRecipesTab(),
            _buildFoodBanksTab(),
            _buildTrackTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
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

          // Spacer to push prediction to bottom
          const Spacer(),

          // Prediction Result Display at the bottom (if available)
          if (_latestPrediction != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 24, bottom: 120),
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
    final String? prediction = await context.push<String>('/camera');
    if (prediction != null) {
      setState(() {
        _latestPrediction = prediction;
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

  Widget _buildRecipesTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Recipe Suggestions'),
          Text('Get personalized recipes based on your produce'),
        ],
      ),
    );
  }

  Widget _buildFoodBanksTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Food Banks'),
          Text('Find local food banks in your area'),
        ],
      ),
    );
  }

  Widget _buildTrackTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Track Produce'),
          Text('Scan QR codes to trace from farm to table'),
        ],
      ),
    );
  }
}