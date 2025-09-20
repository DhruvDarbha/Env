# 🌱 .env - Smart Produce Management Platform

> **Transforming Food Waste into Sustainable Action**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com)

## 🌍 Fighting Food Waste for a Sustainable Future

**One-third of all food produced globally is wasted.** That's 1.3 billion tons of food annually – enough to feed 3 billion people. In the United States alone, food waste costs families an average of $1,500 per year and contributes to 20% of landfill waste, generating methane emissions equivalent to 37 million cars.

**.env** is more than just an app – it's a movement toward sustainable food consumption. By leveraging cutting-edge AI technology and real-time data analytics, we empower consumers, suppliers, and food banks to make informed decisions that reduce waste, save money, and protect our planet.

### 🎯 Our Mission
Transform how we interact with food by providing intelligent insights that:
- **Reduce household food waste** by up to 40% through smart ripeness detection
- **Optimize supply chain efficiency** with predictive analytics
- **Connect surplus food** with communities in need
- **Educate consumers** about sustainable food practices

## 🚀 How .env Works

Food waste is a challenge we're ready to tackle, and at the core of our solution is .env! Our platform is designed to help consumers understand when food needs to be consumed or shared, while empowering suppliers to make informed decisions about sourcing better produce.

### For Consumers
When consumers open the app, they have access to three powerful tools: fruit analysis, AskEnv (our Cerebras-powered AI agent), and food bank discovery for sharing surplus food.

Our fruit analysis feature employs a sophisticated dual-API approach. When users analyze produce, we make two parallel calls: one to Google Gemini for brand detection, and another to our custom GCP ML model. Our proprietary model leverages a cGAN framework to reconstruct standard 3-channel RGB images into multi-channel 720nm images that reveal details beyond the visible spectrum. This advanced imaging technique allows us to detect internal biomarkers like lycopene levels, providing unprecedented insight into true ripeness.

The system returns comprehensive data including ripeness scores, days until expiration, and Newton scale measurements. This information helps consumers avoid consuming spoiled food and identify produce perfect for donation. All data is stored in Supabase along with location metadata and brand information, creating a valuable dataset for our supplier partners.

### For Suppliers
Suppliers gain access to vital intelligence about their produce quality through detailed analytics dashboards. They can see where quality reports are generated, track their brand performance across regions, and take proactive action to improve their supply chain.

### AskEnv AI Assistant
Finally, we have AskEnv, an intelligent agent that has contextual access to users' fruit predictions. AskEnv helps users determine what to create with their produce—whether that's suggesting recipes, recommending recycling options, or providing general guidance. The agent learns user preferences over time and can save personalized recipes, making it a truly adaptive cooking companion.

## ✨ Key Features

### 🤖 AI-Powered Produce Analysis
- **Computer Vision Intelligence**: Advanced ML models analyze produce ripeness using Newton scale measurements (0-15)
- **Brand Detection**: Automatic supplier identification for quality tracking
- **Shelf Life Prediction**: Precise estimates for optimal consumption timing
- **Quality Categorization**: Smart classification as Overripe, Ripe, or Unripe

### 📱 Consumer Dashboard
- **📷 Smart Camera Integration**: Instant produce analysis with live camera or gallery photos
- **🍽️ Recipe Intelligence**: AI-powered recipe suggestions based on available ingredients
- **🏪 Food Bank Locator**: GPS-enabled discovery of nearby food assistance programs
- **💬 AskEnv AI Assistant**: Contextual produce advice with voice interaction

### 📊 Supplier Analytics Platform
- **🗺️ Interactive Heatmaps**: Geographic visualization of produce quality across regions
- **📈 Performance Metrics**: Real-time analytics on ripeness distribution and quality trends
- **📋 Brand Tracking**: Supplier-specific data collection and analysis
- **🎯 Location-Based Insights**: Philadelphia-focused data with user location services

### 🤝 Cross-Platform Accessibility
- **🌐 Web Application**: Full-featured browser experience optimized for desktop
- **📱 Mobile Apps**: Native iOS and Android applications with offline capabilities
- **🔄 Real-Time Sync**: Seamless data synchronization across all platforms

## 🛠️ Technology Stack

### 🎨 Frontend & User Experience
- **Flutter 3.13+** - Cross-platform framework with Material Design 3
- **Dart 3.1+** - Type-safe programming with null safety
- **Provider Pattern** - Reactive state management
- **go_router** - Declarative navigation with authentication guards

### 🧠 AI & Machine Learning
- **Google Gemini Vision API** - Advanced image analysis and brand detection
- **Cerebras LLaMA-3.3-70B** - Conversational AI for produce assistance
- **Custom ML Model** - Proprietary ripeness prediction algorithms
- **Speech Integration** - Voice-to-text and text-to-speech capabilities

### 🗄️ Backend & Database
- **Supabase** - Real-time database with Row Level Security
- **PostgreSQL** - Robust data storage with supplier-specific tables
- **Google Cloud Functions** - Serverless ML model deployment
- **Python Flask** - Microservices for analytics processing

### 🌐 Location & Mapping
- **Google Maps Platform** - Interactive mapping and location services
- **Google Places API** - Food bank discovery and business information
- **Geolocator** - Device location services with permission handling
- **Geocoding** - Address-to-coordinates conversion

### 📊 Data Visualization
- **fl_chart** - Native Flutter charts for analytics dashboards
- **Interactive Heatmaps** - Gradient overlays on Google Maps
- **Real-time Analytics** - Live data updates with performance monitoring

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.13 or higher
- Dart SDK 3.1 or higher
- Node.js for web deployment
- Python 3.8+ for backend services

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/freshtrack-env.git
   cd freshtrack-env
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   ```bash
   # Create API configuration
   cp lib/src/config/api_config_template.dart lib/src/config/api_config.dart
   # Add your API keys for Supabase, Google Maps, etc.
   ```

4. **Run the application**
   ```bash
   # Web development
   flutter run -d web-server --web-port 8080

   # Mobile development
   flutter run

   # Production build
   flutter build web
   flutter build apk
   flutter build ios
   ```

### 🔧 Development Commands
- **Get dependencies**: `flutter pub get`
- **Run tests**: `flutter test`
- **Analyze code**: `flutter analyze`
- **Clean build**: `flutter clean`

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point with providers
├── src/
│   ├── app.dart                # Router with authentication guards
│   ├── providers/              # State management
│   │   ├── app_state.dart      # Global UI state and theme
│   │   └── auth_provider.dart  # Authentication management
│   ├── screens/                # Feature screens
│   │   ├── home_screen.dart    # Landing page
│   │   ├── consumer/           # Consumer dashboard & features
│   │   ├── supplier/           # Supplier analytics platform
│   │   └── chat/               # AI assistance interface
│   ├── models/                 # Data structures
│   │   ├── produce_analysis.dart
│   │   ├── recipe.dart
│   │   ├── user.dart
│   │   └── food_bank.dart
│   ├── services/               # Backend integration
│   │   └── api_service.dart    # Supabase and external APIs
│   ├── widgets/                # Reusable components
│   └── theme/                  # Material Design theming
├── web/                        # Web-specific assets
├── python_chart_service/       # Analytics microservice
└── assets/                     # Images and resources
```

## 🔐 Authentication & Demo Access

### Demo Credentials
- **Supplier Demo**: `sunkist@env.com` / `demo123`
- **Consumer Demo**: `james@env.com` / `demo123`

### Authentication Features
- Dual login flows for consumers and suppliers
- Session persistence with SharedPreferences
- Route guards with automatic redirects
- Secure token management

### Supplier Analytics
- Real-time ripeness distribution charts
- Geographic heatmaps with gradient visualization
- Performance metrics and quality trends
- Philadelphia-focused data concentration

## 🌐 API Integration

### External Services
- **Supabase Database**: Real-time data storage and retrieval
- **Google Gemini**: Image analysis and conversational AI
- **Google Maps Platform**: Location services and mapping
- **Cerebras AI**: Advanced language model for chat

### Custom Endpoints
- **Brand Detection Service**: ML-powered supplier identification
- **Ripeness Prediction API**: Newton scale analysis
- **Food Bank Discovery**: Location-based search with caching

## 🎨 Design & User Experience

### Material Design 3
- Green-focused color scheme reflecting sustainability
- Light and dark theme support
- Accessible design with proper contrast ratios
- Responsive layouts for all screen sizes

### Platform-Specific Assets
- **Web**: `web_app_background.png`, `web_app_splash.png`
- **Mobile**: `splash_screen.png`, `login_screen.png`
- **Icons**: Lucide icon set for modern aesthetics

## 🔄 Development Workflow

### Code Quality
- Flutter lints with standard recommendations
- Type safety with null safety enforcement
- Comprehensive error handling and fallbacks
- Performance optimization with lazy loading

### Testing & Deployment
- Unit tests for core functionality
- Integration tests for API endpoints
- Web deployment with Progressive Web App support
- Mobile app store distribution

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 Acknowledgments

- **Google AI** for Gemini Vision and language models
- **Supabase** for real-time database infrastructure
- **Flutter Team** for the cross-platform framework
- **OpenAI** for early AI research inspiration
- **Food waste researchers** worldwide for sustainability insights

## 📞 Support

For technical support or questions about sustainable food practices:
- 📧 Email: farzadh@umich.edh, ddarbha@wharton.upenn.edu, shivv1@uw.edu

---

**Together, we can build a world where no food goes to waste. Every scan, every insight, every action brings us closer to a sustainable future.**

*Made with 💚 for a sustainable planet*
