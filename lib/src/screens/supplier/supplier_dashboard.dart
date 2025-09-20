import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';

import '../../providers/auth_provider.dart';
import '../../widgets/background_wrapper_light.dart';

class HeatmapDataPoint {
  final double latitude;
  final double longitude;
  final double intensity;

  HeatmapDataPoint({
    required this.latitude,
    required this.longitude,
    required this.intensity,
  });
}

class SupplierDashboard extends StatefulWidget {
  const SupplierDashboard({super.key});

  @override
  State<SupplierDashboard> createState() => _SupplierDashboardState();
}

class _SupplierDashboardState extends State<SupplierDashboard> {
  List<Map<String, dynamic>> supplierData = [];
  Map<String, dynamic>? summary;
  bool isLoading = true;
  String? errorMessage;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // Get sunkist_data
      String tableName = 'sunkist_data';

      final sunkistResponse = await supabase
          .from(tableName)
          .select()
          .order('analyzed_at', ascending: true);

      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(sunkistResponse);

      if (data.isEmpty) {
        setState(() {
          errorMessage = 'No data found in any tables. Please check Supabase connection.';
          isLoading = false;
        });
        return;
      }

      // Calculate summary
      final ripenessScores = data
          .where((item) => item['ripeness_score'] != null)
          .map((item) => (item['ripeness_score'] as num).toDouble())
          .toList();

      final avgRipeness = ripenessScores.isNotEmpty
          ? ripenessScores.reduce((a, b) => a + b) / ripenessScores.length
          : 0.0;

      String qualityGrade;
      if (avgRipeness >= 7) {
        qualityGrade = 'Excellent';
      } else if (avgRipeness >= 4) {
        qualityGrade = 'Good';
      } else {
        qualityGrade = 'Needs Attention';
      }

      setState(() {
        supplierData = data;
        summary = {
          'total_analyses': data.length,
          'average_ripeness': avgRipeness,
          'quality_grade': qualityGrade,
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading analytics: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapperLight(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Sunkist Analytics'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  context.go('/');
                },
                icon: const Icon(Icons.logout),
                color: Colors.black87,
              ),
            ),
          ],
        ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red.shade400),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: _loadAnalytics,
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      if (summary != null) _buildSummaryCards(),
                      const SizedBox(height: 28),

                      // Ripeness Chart
                      _buildRipenessChart(),
                      const SizedBox(height: 28),

                      // Shelf Life Chart
                      _buildShelfLifeChart(),
                      const SizedBox(height: 28),

                      // Location Heatmap
                      _buildLocationHeatmap(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Analyses',
            summary!['total_analyses'].toString(),
            Icons.analytics,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Avg Ripeness',
            summary!['average_ripeness'].toStringAsFixed(1),
            Icons.apple,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Quality Grade',
            summary!['quality_grade'],
            Icons.star,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRipenessChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ripeness Scores Over Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              child: supplierData.isEmpty
                  ? const Center(child: Text('No data available'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < supplierData.length && value.toInt() >= 0) {
                                  final item = supplierData[value.toInt()];
                                  if (item['analyzed_at'] != null) {
                                    final date = DateTime.parse(item['analyzed_at']);
                                    return Text(
                                      '${date.month}/${date.day}',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  }
                                }
                                return const Text('');
                              },
                              reservedSize: 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: supplierData.asMap().entries.map((entry) {
                              final ripeness = (entry.value['ripeness_score'] as num?)?.toDouble() ?? 0.0;
                              return FlSpot(entry.key.toDouble(), ripeness);
                            }).toList(),
                            isCurved: true,
                            gradient: LinearGradient(
                              colors: [Colors.orange.shade400, Colors.orange.shade700],
                            ),
                            barWidth: 3,
                            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                              Color dotColor;
                              if (spot.y <= 3) dotColor = Colors.red;
                              else if (spot.y <= 7) dotColor = Colors.orange;
                              else dotColor = Colors.green;
                              return FlDotCirclePainter(
                                radius: 4,
                                color: dotColor,
                                strokeColor: Colors.white,
                                strokeWidth: 1,
                              );
                            }),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.withOpacity(0.3),
                                  Colors.orange.withOpacity(0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        minY: 0,
                        maxY: 15,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShelfLifeChart() {
    // Calculate shelf life data grouped by date
    Map<String, List<double>> dailyShelfLife = {};

    for (var item in supplierData) {
      if (item['analyzed_at'] != null && item['ripeness_score'] != null) {
        final date = DateTime.parse(item['analyzed_at']);
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final ripenessScore = (item['ripeness_score'] as num).toDouble();

        // Convert ripeness to shelf life
        double shelfLife;
        if (ripenessScore <= 3) {
          shelfLife = 1.5;
        } else if (ripenessScore <= 7) {
          shelfLife = 4.0;
        } else {
          shelfLife = 8.0;
        }

        dailyShelfLife.putIfAbsent(dateKey, () => []);
        dailyShelfLife[dateKey]!.add(shelfLife);
      }
    }

    // Calculate averages and create chart spots
    List<FlSpot> shelfLifeSpots = [];
    List<String> dateLabels = [];

    final sortedDates = dailyShelfLife.keys.toList()..sort();
    for (int i = 0; i < sortedDates.length; i++) {
      final dateKey = sortedDates[i];
      final shelfLives = dailyShelfLife[dateKey]!;
      final averageShelfLife = shelfLives.reduce((a, b) => a + b) / shelfLives.length;

      shelfLifeSpots.add(FlSpot(i.toDouble(), averageShelfLife));
      final date = DateTime.parse(dateKey);
      dateLabels.add('${date.month}/${date.day}');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Average Shelf Life Over Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              child: shelfLifeSpots.isEmpty
                  ? const Center(child: Text('No shelf life data available'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < dateLabels.length && value.toInt() >= 0) {
                                  return Text(
                                    dateLabels[value.toInt()],
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()} days',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                              reservedSize: 60,
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: shelfLifeSpots,
                            isCurved: true,
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.blue.shade700],
                            ),
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 5,
                                  color: Colors.blue.shade600,
                                  strokeColor: Colors.white,
                                  strokeWidth: 2,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.3),
                                  Colors.blue.withOpacity(0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        minY: 0,
                        maxY: 10,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeatmap() {
    if (supplierData.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ripeness Location Heatmap',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                child: const Center(
                  child: Text('No location data available'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate center point and collect data points
    double totalLat = 0;
    double totalLng = 0;
    int validLocationCount = 0;
    List<HeatmapDataPoint> heatmapData = [];

    for (var item in supplierData) {
      if (item['latitude'] != null && item['longitude'] != null && item['ripeness_score'] != null) {
        double lat = (item['latitude'] as num).toDouble();
        double lng = (item['longitude'] as num).toDouble();
        double ripeness = (item['ripeness_score'] as num).toDouble();

        totalLat += lat;
        totalLng += lng;
        validLocationCount++;

        // Convert ripeness score (0-15) to heat intensity
        double intensity = ripeness / 15.0; // Normalize to 0-1

        heatmapData.add(HeatmapDataPoint(
          latitude: lat,
          longitude: lng,
          intensity: intensity,
        ));
      }
    }

    if (validLocationCount == 0) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ripeness Location Heatmap',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                child: const Center(
                  child: Text('No valid location data available'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default to Philadelphia center, or use data center if no Philadelphia data
    LatLng center = heatmapData.isNotEmpty
        ? LatLng(totalLat / validLocationCount, totalLng / validLocationCount)
        : const LatLng(39.9526, -75.1652); // Philadelphia Center

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ripeness Location Heatmap',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Color scale legend
                _buildHeatmapLegend(),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: center,
                        zoom: 9,
                      ),
                      mapType: MapType.normal,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      circles: _createHeatmapCircles(heatmapData),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: _goToUserLocation,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Gradient colors represent ripeness levels: Green (low), Yellow (medium), Orange (high), Red (critical attention needed).',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Create heatmap effect using multiple overlapping circles with gradients
  Set<Circle> _createHeatmapCircles(List<HeatmapDataPoint> dataPoints) {
    Set<Circle> circles = {};

    for (int i = 0; i < dataPoints.length; i++) {
      var point = dataPoints[i];

      // Create multiple concentric circles for gradient effect
      for (int j = 0; j < 4; j++) {
        double radius = (4 - j) * 1000.0; // 4km, 3km, 2km, 1km
        double opacity = (point.intensity * 0.15) / (j + 1); // More transparent to show background map

        Color baseColor = _getHeatColor(point.intensity);

        circles.add(
          Circle(
            circleId: CircleId('heat_${i}_${j}'),
            center: LatLng(point.latitude, point.longitude),
            radius: radius,
            fillColor: baseColor.withOpacity(opacity),
            strokeColor: Colors.transparent,
            strokeWidth: 0,
          ),
        );
      }
    }

    return circles;
  }

  Color _getHeatColor(double intensity) {
    if (intensity <= 0.2) {
      return const Color(0xFF00FF00); // Green
    } else if (intensity <= 0.5) {
      return const Color(0xFFFFFF00); // Yellow
    } else if (intensity <= 0.75) {
      return const Color(0xFFFFA500); // Orange
    } else {
      return const Color(0xFFFF0000); // Red
    }
  }

  Future<void> _goToUserLocation() async {
    if (_mapController == null) return;

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied.')),
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Animate to user location
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Widget _buildHeatmapLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Low',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 4),
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00FF00), // Green
                  Color(0xFFFFFF00), // Yellow
                  Color(0xFFFFA500), // Orange
                  Color(0xFFFF0000), // Red
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'High',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

