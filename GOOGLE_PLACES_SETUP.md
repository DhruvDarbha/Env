# Google Places API Setup Instructions

To enable real food bank location search, you need to configure the Google Places API.

## Steps:

1. **Get Google Cloud Console Access**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing project

2. **Enable Required APIs**
   - Navigate to "APIs & Services" > "Library"
   - Enable the following APIs:
     - **Places API** (required for food bank search)
     - **Maps SDK for iOS** (if using iOS)
     - **Maps SDK for Android** (if using Android)
     - **Geocoding API** (already used for zip code conversion)

3. **Create API Credentials**
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "API Key"
   - Copy the generated API key

4. **Configure API Key in App**
   - Open `lib/src/config/api_config.dart`
   - Replace `YOUR_GOOGLE_PLACES_API_KEY` with your actual API key:
   ```dart
   static const String googlePlacesApiKey = 'AIzaSyC-YOUR_ACTUAL_API_KEY_HERE';
   ```

5. **Secure the API Key (Recommended)**
   - In Google Cloud Console, restrict the API key:
     - Set application restrictions (iOS bundle ID, Android package name)
     - Set API restrictions to only the APIs you're using

6. **iOS Configuration (if using iOS)**
   - Add API key to `ios/Runner/Info.plist`:
   ```xml
   <key>GoogleMapsAPIKey</key>
   <string>YOUR_API_KEY_HERE</string>
   ```

7. **Android Configuration (if using Android)**
   - Add API key to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE" />
   ```

## Cost Considerations:

- Google Places API has usage-based pricing
- Text Search: $32 per 1000 requests
- Place Details: $17 per 1000 requests
- Consider setting up billing alerts and quotas

## Fallback Behavior:

If the API key is not configured, the app will automatically fall back to mock/sample food bank data for development purposes.

## Testing:

After configuration:
1. Restart the Flutter app
2. Navigate to Food Banks tab
3. Enter a zip code or use current location
4. Verify real food bank locations appear on the map