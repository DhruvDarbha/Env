import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/food_bank.dart';
import '../services/api_service.dart';

class FoodBankMap extends StatefulWidget {
  final String? zipCode;
  final Position? userLocation;
  final Function(FoodBank)? onFoodBankSelected;

  const FoodBankMap({
    super.key,
    this.zipCode,
    this.userLocation,
    this.onFoodBankSelected,
  });

  @override
  State<FoodBankMap> createState() => _FoodBankMapState();
}

class _FoodBankMapState extends State<FoodBankMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<FoodBank> _foodBanks = [];
  Position? _currentLocation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didUpdateWidget(FoodBankMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Re-initialize map when zipCode or userLocation changes
    if (widget.zipCode != oldWidget.zipCode || 
        widget.userLocation != oldWidget.userLocation) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      _initializeMap();
    }
  }

  Future<void> _initializeMap() async {
    try {
      Position? location = widget.userLocation;

      // If no location provided, try to get current location or use zipcode
      if (location == null) {
        if (widget.zipCode != null && widget.zipCode!.isNotEmpty) {
          location = await ApiService.getLocationFromZipCode(widget.zipCode!);
        } else {
          location = await ApiService.getCurrentLocation();
        }
      }

      if (location == null) {
        setState(() {
          _error = 'Unable to determine location. Please enable location services or provide a valid zip code.';
          _isLoading = false;
        });
        return;
      }

      _currentLocation = location;

      // Search for nearby food banks
      _foodBanks = await ApiService.searchFoodBanksByLocation(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      // Create markers for food banks
      _createMarkers();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading map data: $e';
        _isLoading = false;
      });
    }
  }

  void _createMarkers() {
    final markers = <Marker>{};

    // Add user location marker
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current location',
          ),
        ),
      );
    }

    // Add food bank markers
    for (final foodBank in _foodBanks) {
      markers.add(
        Marker(
          markerId: MarkerId(foodBank.id),
          position: LatLng(foodBank.latitude, foodBank.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: foodBank.name,
            snippet: '${foodBank.distanceString} • ${foodBank.operatingHours}',
          ),
          onTap: () {
            if (widget.onFoodBankSelected != null) {
              widget.onFoodBankSelected!(foodBank);
            }
            _showFoodBankDetails(foodBank);
          },
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _showFoodBankDetails(FoodBank foodBank) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.8,
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

                  // Food bank name
                  Text(
                    foodBank.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Distance
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green[600], size: 20),
                      const SizedBox(width: 4),
                      Text(
                        foodBank.distanceString,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Address
                  _buildDetailSection(
                    icon: Icons.place,
                    title: 'Address',
                    content: foodBank.address,
                  ),

                  // Operating hours
                  _buildDetailSection(
                    icon: Icons.access_time,
                    title: 'Operating Hours',
                    content: foodBank.operatingHours,
                  ),

                  // Available produce
                  _buildDetailSection(
                    icon: Icons.eco,
                    title: 'Available Produce',
                    content: foodBank.availableProduce,
                  ),

                  // Phone number
                  if (foodBank.phoneNumber != null)
                    _buildDetailSection(
                      icon: Icons.phone,
                      title: 'Phone',
                      content: foodBank.phoneNumber!,
                      isClickable: true,
                    ),

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Open directions
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Call phone number
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    bool isClickable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    color: isClickable ? Colors.blue[600] : Colors.black87,
                    decoration: isClickable ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentLocation == null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Location Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please enable location services',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
            zoom: 13.0,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}