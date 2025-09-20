import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/prediction_service.dart';
import '../services/api_service.dart';
import '../services/gemini_vision_service.dart';
import '../models/produce_analysis.dart';

class PhotoAnalysisScreen extends StatefulWidget {
  final String imagePath;
  
  const PhotoAnalysisScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<PhotoAnalysisScreen> createState() => _PhotoAnalysisScreenState();
}

class _PhotoAnalysisScreenState extends State<PhotoAnalysisScreen> {
  bool _isAnalyzing = false;
  String? _detectedBrand;
  String? _ripenessScore;

  /// Extract numerical ripeness value from formatted GCP response
  double _extractRipenessValue(String formattedResult) {
    try {
      // Look for pattern "Ripeness: X.XX Newtons"
      final RegExp ripenessRegex = RegExp(r'Ripeness:\s*(\d+\.?\d*)\s*Newtons');
      final Match? match = ripenessRegex.firstMatch(formattedResult);

      if (match != null && match.group(1) != null) {
        return double.parse(match.group(1)!);
      }

      // Fallback: try to parse the first number found in the string
      final RegExp numberRegex = RegExp(r'(\d+\.?\d*)');
      final Match? numberMatch = numberRegex.firstMatch(formattedResult);

      if (numberMatch != null && numberMatch.group(1) != null) {
        return double.parse(numberMatch.group(1)!);
      }

      print('⚠️ Could not extract ripeness value from: $formattedResult');
      return 0.0;
    } catch (e) {
      print('⚠️ Error extracting ripeness value: $e');
      return 0.0;
    }
  }

  Future<void> _getPrediction() async {
    setState(() {
      _isAnalyzing = true;
      _detectedBrand = null;
      _ripenessScore = null;
    });

    try {
      // Run GCP ripeness prediction and Gemini brand detection
      final String ripenessResult = await PredictionService.predictRipeness(widget.imagePath);
      final String? detectedBrand = await GeminiVisionService.detectFruitBrand(widget.imagePath);

      // If brand was detected, sync to Supabase with REAL ripeness score
      if (detectedBrand != null) {
        // Extract numerical value from formatted result
        final realRipenessScore = _extractRipenessValue(ripenessResult);
        print('📊 Extracted ripeness value: $realRipenessScore from: $ripenessResult');
        await ApiService.syncBrandToSupabase(
          brandName: detectedBrand,
          ripenessScore: realRipenessScore,
          analyzedAt: DateTime.now(),
          location: await ApiService.getCurrentLocation(),
          fruitType: 'Orange', // You can make this dynamic based on detection
        );
      }

      setState(() {
        _ripenessScore = ripenessResult;
        _detectedBrand = detectedBrand;
        _isAnalyzing = false;
      });

      print('🎯 Analysis Results:');
      print('   Ripeness Score: $ripenessResult');
      print('   Detected Brand: ${detectedBrand ?? "None"}');

      // Return to dashboard with prediction result
      if (mounted) {
        context.pop(ripenessResult);
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      // Show detailed error message
      if (mounted) {
        print('Prediction error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/consumer'),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Photo Analysis',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/consumer'),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Display
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Error loading image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),


            // Analysis Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.analytics_outlined,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AI Food Analysis',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get insights about freshness, quality, and storage recommendations',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Results Display (if available)
                  if (_ripenessScore != null || _detectedBrand != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Analysis Results',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_ripenessScore != null)
                            Row(
                              children: [
                                const Icon(Icons.assessment, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Text('Ripeness Score: $_ripenessScore'),
                              ],
                            ),
                          if (_detectedBrand != null)
                            Row(
                              children: [
                                const Icon(Icons.label, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Text('Brand Detected: $_detectedBrand'),
                              ],
                            ),
                          if (_detectedBrand == null && _ripenessScore != null)
                            const Row(
                              children: [
                                Icon(Icons.label_off, size: 16, color: Colors.grey),
                                SizedBox(width: 8),
                                Text('No brand detected', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Get Prediction Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isAnalyzing ? null : _getPrediction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isAnalyzing
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Analyzing Ripeness & Brand...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Analyze Ripeness & Brand',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Retake Photo Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => context.go('/camera'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Take Another Photo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
}
