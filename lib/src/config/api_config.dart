class ApiConfig {
  // Google API Keys
  // IMPORTANT: Replace with your actual Google API keys
  // Get your API keys from: https://console.cloud.google.com/

  // Google Places API Key
  // Enable: Places API, Maps SDK for iOS/Android
  static const String googlePlacesApiKey = 'AIzaSyBvliiQSooQGNzWZaFjl87lsk9J-X5kPdw';

  // Google Generative AI (Gemini) API Key
  // Enable: Generative Language API
  static const String geminiApiKey = 'AIzaSyDhirAR-Szj9bH6WyNm0a8LP1yKzZj7DfA';

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

  static bool get isGeminiApiKeyConfigured {
    return geminiApiKey != 'YOUR_GEMINI_API_KEY' &&
           geminiApiKey.isNotEmpty;
  }
}