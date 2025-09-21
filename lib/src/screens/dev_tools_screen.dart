import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

class DevToolsScreen extends StatefulWidget {
  const DevToolsScreen({super.key});

  @override
  State<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends State<DevToolsScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  Future<void> _insertHalosDummyData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Inserting Halos dummy data...';
    });

    try {
      final success = await ApiService.insertHalosDummyData();
      setState(() {
        _statusMessage = success
            ? 'Successfully inserted 30 Halos data points!'
            : 'Failed to insert Halos dummy data';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _insertVillitaDummyData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Inserting Villita dummy data...';
    });

    try {
      final success = await ApiService.insertVillitaDummyData();
      setState(() {
        _statusMessage = success
            ? 'Successfully inserted 30 Villita data points with ripeness scores 0-6!'
            : 'Failed to insert Villita dummy data';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkSupabaseStatus() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking Supabase connection...';
    });

    try {
      if (SupabaseService.isReady) {
        final brands = await SupabaseService.getAllBrandNames();
        setState(() {
          _statusMessage = 'Supabase connected! Found ${brands.length} brand tables: ${brands.join(', ')}';
        });
      } else {
        setState(() {
          _statusMessage = 'Supabase not configured or not ready';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Supabase error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGeminiDataFormat() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Gemini data format compatibility...';
    });

    try {
      // Simulate Gemini detection result
      final testBrand = 'Halos';
      final testRipeness = 85.5;
      final testFruitType = 'Orange';
      final testAnalyzedAt = DateTime.now();

      // Mock location (UPenn coordinates)
      final testLocation = Position(
        latitude: 39.9522,
        longitude: -75.1932,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      // Test the data insertion
      final success = await SupabaseService.insertBrandData(
        brandName: testBrand,
        ripenessScore: testRipeness,
        analyzedAt: testAnalyzedAt,
        location: testLocation,
        fruitType: testFruitType,
      );

      setState(() {
        if (success) {
          _statusMessage = '''✅ Gemini data format test PASSED!

Data format compatibility verified:
• Brand: $testBrand
• Ripeness: $testRipeness
• Fruit Type: $testFruitType
• Location: ${testLocation.latitude}, ${testLocation.longitude}
• Timestamp: ${testAnalyzedAt.toIso8601String()}

Ready for real Gemini integration!''';
        } else {
          _statusMessage = '❌ Gemini data format test FAILED - Could not insert test data';
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Test failed with error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Development Tools'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supabase Development Tools',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        border: Border.all(color: Colors.amber.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Setup Required:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Go to your Supabase SQL Editor\n'
                            '2. Run HALOS_DUMMY_DATA.sql script\n'
                            '3. Create villita_data table with same schema\n'
                            '4. Click "Insert Halos Dummy Data" or "Insert Villita Dummy Data"',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _checkSupabaseStatus,
                      icon: const Icon(Icons.storage),
                      label: const Text('Check Supabase Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _insertHalosDummyData,
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Insert Halos Dummy Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _insertVillitaDummyData,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Insert Villita Dummy Data (0-6)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testGeminiDataFormat,
                      icon: const Icon(Icons.science),
                      label: const Text('Test Gemini Data Format'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_statusMessage.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_isLoading)
                        const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Expanded(child: Text('Working...')),
                          ],
                        )
                      else
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            color: _statusMessage.contains('Successfully') || _statusMessage.contains('connected')
                                ? Colors.green.shade700
                                : _statusMessage.contains('Error') || _statusMessage.contains('Failed')
                                    ? Colors.red.shade700
                                    : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            Text(
              'Development Mode Only',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}