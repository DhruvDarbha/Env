# CLAUDE_FLUTTER.md

This file provides guidance to Claude Code (claude.ai/code) when working with the Flutter version of FreshTrack.

## Project Overview

FreshTrack is now a Flutter application for smart produce management and food waste reduction. It provides cross-platform mobile and web support with native performance.

## Development Commands

- **Get dependencies**: `flutter pub get`
- **Run app**: `flutter run`
- **Build APK**: `flutter build apk`
- **Build iOS**: `flutter build ios`
- **Build web**: `flutter build web`
- **Run tests**: `flutter test`
- **Analyze code**: `flutter analyze`

## Architecture

### Core Structure
- **Flutter Framework**: Uses Flutter 3.13+ with Dart 3.1+
- **Navigation**: go_router for declarative routing with authentication guards
- **State Management**: Provider pattern for reactive state management
- **UI Design**: Material Design 3 with custom green theme
- **Responsive**: Adaptive layouts for mobile, tablet, and desktop

### Key Components
- `lib/main.dart`: Main app entry point with provider setup
- `lib/src/app.dart`: App router configuration and route definitions
- **Screens**: Organized by feature (home, consumer, supplier, chat)
- **Widgets**: Reusable UI components
- **Providers**: State management for app state and authentication
- **Models**: Data models for messages and other entities

### Configuration
- **Dart**: Modern Dart with null safety
- **Dependencies**: Core packages include provider, go_router, fl_chart, lucide_icons
- **Assets**: Images, fonts (GeistSans, GeistMono), and icons
- **Themes**: Light and dark themes with green color scheme

### Project Structure
```
lib/
├── main.dart                    # App entry point
├── src/
│   ├── app.dart                # Router configuration
│   ├── providers/              # State management
│   │   ├── app_state.dart      # Global app state
│   │   └── auth_provider.dart  # Authentication state
│   ├── screens/                # Main screens
│   │   ├── home_screen.dart    # Landing page
│   │   ├── consumer/           # Consumer features
│   │   ├── supplier/           # Supplier features
│   │   └── chat/               # Chat interface
│   ├── widgets/                # Reusable components
│   │   ├── navigation_bar.dart # App navigation
│   │   ├── hero_section.dart   # Landing hero
│   │   ├── user_type_selector.dart
│   │   ├── feature_cards.dart
│   │   └── chat_interface.dart
│   ├── models/                 # Data models
│   │   └── message.dart        # Chat message model
│   └── theme/
│       └── app_theme.dart      # App theming
```

### Authentication
Provider-based authentication with demo credentials:
- Email: supplier@freshtrack.com
- Password: demo123

### Features Implemented
- **Home Screen**: Hero section, user type selector, feature cards
- **Consumer Dashboard**: Tabbed interface for photo analysis, recipes, food banks, tracking
- **Supplier Dashboard**: Analytics with charts, metrics cards, tabbed data views
- **Chat Interface**: AI assistant with message history
- **Authentication**: Login flow with form validation
- **Navigation**: Responsive navigation with mobile menu
- **Theming**: Green-focused theme with light/dark mode support

### State Management Pattern
Uses Provider pattern:
- `AppState`: Global UI state, theme mode, current view
- `AuthProvider`: Authentication state, login/logout, loading states

### Dependencies
- **provider**: State management
- **go_router**: Navigation and routing
- **fl_chart**: Charts and data visualization
- **lucide_icons**: Icon set
- **image_picker**: Photo selection (for future implementation)
- **qr_code_scanner**: QR code functionality (for future implementation)

### Development Notes
- Responsive design with adaptive layouts
- Material Design 3 components
- Accessibility considerations
- Performance optimized widgets
- Mock data and simulated API responses
- Cross-platform compatibility (iOS, Android, Web)