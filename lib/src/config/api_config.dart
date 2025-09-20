class ApiConfig {
  // Google Places API Key
  // IMPORTANT: Replace with your actual Google Places API key
  // Get your API key from: https://console.cloud.google.com/
  // Enable the following APIs:
  // - Places API
  // - Maps SDK for iOS (if using iOS)
  // - Maps SDK for Android (if using Android)
  static const String googlePlacesApiKey = 'AIzaSyBvliiQSooQGNzWZaFjl87lsk9J-X5kPdw';

  // Base URLs
  static const String googlePlacesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String freshTrackBaseUrl = 'https://api.freshtrack.com';

  // API Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxFoodBankResults = 10;
  static const double defaultSearchRadiusMiles = 10.0;

  // Search queries for food assistance locations
  static const List<String> foodBankSearchQueries = [
    'food bank',
    'food pantry',
    'food assistance',
    'soup kitchen',
    'community kitchen',
    'food distribution center',
    'charitable organization food',
    'salvation army food',
    'food shelf',
  ];

  // Validation
  static bool get isGoogleApiKeyConfigured {
    return googlePlacesApiKey != 'YOUR_GOOGLE_PLACES_API_KEY' &&
           googlePlacesApiKey.isNotEmpty;
  }
}