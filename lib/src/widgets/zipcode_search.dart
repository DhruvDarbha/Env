import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZipCodeSearch extends StatefulWidget {
  final Function(String) onSearch;
  final Function()? onUseCurrentLocation;
  final bool isLoading;
  final String? initialZipCode;

  const ZipCodeSearch({
    super.key,
    required this.onSearch,
    this.onUseCurrentLocation,
    this.isLoading = false,
    this.initialZipCode,
  });

  @override
  State<ZipCodeSearch> createState() => _ZipCodeSearchState();
}

class _ZipCodeSearchState extends State<ZipCodeSearch> {
  final TextEditingController _zipCodeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialZipCode != null) {
      _zipCodeController.text = widget.initialZipCode!;
    }
  }

  @override
  void dispose() {
    _zipCodeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    final zipCode = _zipCodeController.text.trim();
    if (zipCode.isNotEmpty && _isValidZipCode(zipCode)) {
      widget.onSearch(zipCode);
      _focusNode.unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 5-digit ZIP code'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  bool _isValidZipCode(String zipCode) {
    // Simple validation for 5-digit US ZIP codes
    return RegExp(r'^\d{5}$').hasMatch(zipCode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.green[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Find Food Banks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _zipCodeController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter ZIP code (e.g., 48104)',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.green[600]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                  enabled: !widget.isLoading,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: widget.isLoading ? null : _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Search'),
              ),
            ],
          ),

          // Current location option
          if (widget.onUseCurrentLocation != null) ...[
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.isLoading ? null : widget.onUseCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use Current Location'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.green[600]!),
                  foregroundColor: Colors.green[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],

          // Help text
          const SizedBox(height: 12),
          Text(
            'Enter your ZIP code to find food banks in your area. We\'ll show you the nearest locations with fresh produce.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}