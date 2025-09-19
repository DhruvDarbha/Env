# FreshTrack Flutter

Smart produce management and food waste reduction app built with Flutter.

## Overview

FreshTrack has been converted from a Next.js React application to a Flutter cross-platform app. This version provides native mobile performance while maintaining the same feature set and user experience.

## Features

### Consumer Features
- **Photo Analysis**: Upload produce photos for AI-powered ripeness and quality analysis
- **Recipe Recommendations**: Get personalized recipe suggestions based on available produce
- **Food Bank Locator**: Find local food banks and available produce in your area
- **Supply Chain Tracking**: Scan QR codes to trace produce from farm to table

### Supplier Features
- **Quality Analytics Dashboard**: Track quality metrics and trends with interactive charts
- **Distribution Management**: Monitor regional distribution and performance
- **AI-Powered Insights**: Get intelligent recommendations for supply chain optimization
- **Real-time Alerts**: Receive notifications about quality issues and logistics updates

### Shared Features
- **AI Chat Assistant**: Get instant help with produce questions and recommendations
- **Responsive Design**: Optimized for mobile, tablet, and desktop
- **Dark/Light Themes**: Adaptive theming with green color scheme
- **Authentication**: Secure supplier portal access

## Getting Started

### Prerequisites
- Flutter SDK 3.13.0 or higher
- Dart SDK 3.1.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building

- **Android APK**: `flutter build apk`
- **iOS**: `flutter build ios`
- **Web**: `flutter build web`

## Architecture

### State Management
Uses Provider pattern for reactive state management:
- `AppState`: Global UI state and theme management
- `AuthProvider`: Authentication state and user sessions

### Navigation
go_router for declarative routing with:
- Route guards for authenticated content
- Deep linking support
- Web URL support

### UI Design
Material Design 3 with:
- Custom green theme reflecting produce focus
- Responsive layouts for all screen sizes
- Accessibility features built-in

## Demo Credentials

For supplier login:
- **Email**: supplier@freshtrack.com
- **Password**: demo123

## Project Structure

```
lib/
├── main.dart                   # App entry point
├── src/
│   ├── app.dart               # Router configuration
│   ├── providers/             # State management
│   ├── screens/               # App screens
│   ├── widgets/               # Reusable UI components
│   ├── models/                # Data models
│   └── theme/                 # App theming
```

## Development

### Code Quality
- `flutter analyze` - Static analysis
- `flutter test` - Run unit tests
- `flutter format .` - Code formatting

### Adding Features
1. Create models in `lib/src/models/`
2. Add screens in appropriate feature folders
3. Create reusable widgets in `lib/src/widgets/`
4. Update providers for state management
5. Add routes in `lib/src/app.dart`

## Conversion Notes

This Flutter app maintains feature parity with the original React/Next.js version:

### Converted Components
- ✅ Navigation system with responsive mobile menu
- ✅ Hero section and landing page
- ✅ User type selector with cards
- ✅ Feature overview cards
- ✅ Consumer dashboard with tabs
- ✅ Supplier dashboard with analytics
- ✅ Chat interface with message history
- ✅ Authentication flow
- ✅ Theme system with light/dark modes

### Future Enhancements
- Photo picker integration for produce analysis
- QR code scanner for supply chain tracking
- Real API integration
- Push notifications for alerts
- Offline data caching
- Geolocation for food bank finder

## Contributing

1. Follow Flutter style guidelines
2. Use Provider pattern for state management
3. Maintain responsive design principles
4. Add tests for new features
5. Update documentation as needed

## License

This project is part of the FreshTrack ecosystem for sustainable produce management.