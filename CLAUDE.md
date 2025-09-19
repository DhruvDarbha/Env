# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FreshTrack (app name: "Savr") is a Flutter application for smart produce management and food waste reduction. It provides cross-platform mobile and web support with native performance, featuring consumer and supplier dashboards with AI chat assistance.

## Development Commands

- **Get dependencies**: `flutter pub get`
- **Run app**: `flutter run`
- **Run tests**: `flutter test`
- **Analyze code**: `flutter analyze`
- **Build APK**: `flutter build apk`
- **Build iOS**: `flutter build ios`
- **Build web**: `flutter build web`
- **Clean build**: `flutter clean`

## Architecture

### Core Structure
- **Flutter Framework**: Uses Flutter 3.13+ with Dart 3.1+ and null safety
- **Navigation**: go_router for declarative routing with authentication guards and redirects
- **State Management**: Provider pattern for reactive state management across the app
- **UI Design**: Material Design 3 with custom green-focused theme and light/dark mode support
- **Cross-Platform**: Supports iOS, Android, and Web with responsive layouts

### Key Components
- `lib/main.dart`: App entry point with MultiProvider setup for state management
- `lib/src/app.dart`: Router configuration with authentication guards and route definitions
- **Screens**: Feature-organized screens (home, consumer, supplier, chat, camera)
- **Providers**: State management classes (AppState, AuthProvider)
- **Models**: Data models for user, produce analysis, recipes, messages, etc.
- **Widgets**: Reusable UI components and background wrappers
- **Services**: API service layer for backend communication

### Project Structure
```
lib/
├── main.dart                    # App entry point with providers
├── src/
│   ├── app.dart                # Router with auth guards
│   ├── providers/              # State management
│   │   ├── app_state.dart      # Global UI state, theme mode
│   │   └── auth_provider.dart  # Authentication state
│   ├── screens/                # Main screens
│   │   ├── home_screen.dart    # Landing page
│   │   ├── splash_screen.dart  # Initial splash screen
│   │   ├── camera_screen.dart  # Camera functionality
│   │   ├── consumer/           # Consumer login & dashboard
│   │   ├── supplier/           # Supplier login & dashboard
│   │   └── chat/               # AI chat interface
│   ├── widgets/                # Reusable components
│   │   ├── chat_interface.dart # Chat UI components
│   │   └── background_wrapper*.dart # Background styling
│   ├── models/                 # Data models
│   │   ├── user.dart           # User model
│   │   ├── message.dart        # Chat message model
│   │   ├── produce_analysis.dart
│   │   ├── recipe.dart
│   │   └── food_bank.dart
│   ├── services/
│   │   └── api_service.dart    # Backend API integration
│   └── theme/
│       └── app_theme.dart      # Material 3 theming
```

### Authentication
Provider-based authentication system with separate consumer and supplier flows:
- **Consumer**: Simple authentication flow
- **Supplier**: Demo credentials (supplier@freshtrack.com / demo123)
- **Route Guards**: Automatic redirects to login screens for protected routes
- **State Persistence**: Authentication state managed through AuthProvider

### State Management Pattern
Uses Provider pattern with two main providers:
- **AppState**: Global UI state, theme mode (light/dark), loading states
- **AuthProvider**: Authentication state, login/logout logic, user session management

### Key Dependencies
- **provider**: State management and dependency injection
- **go_router**: Declarative routing with authentication guards
- **fl_chart**: Charts and data visualization for analytics
- **lucide_icons**: Modern icon set
- **image_picker** & **camera**: Photo capture functionality
- **qr_code_scanner**: QR code scanning capabilities
- **shared_preferences**: Local data persistence
- **google_fonts**: Typography management
- **http**: Network requests and API communication

### Development Notes
- **Linting**: Uses flutter_lints with standard Flutter recommendations
- **Code Analysis**: Run `flutter analyze` before commits
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Material Design 3**: Modern UI components with accessibility support
- **Mock Data**: Development uses simulated API responses
- **Hot Reload**: Flutter's fast development cycle with hot reload support