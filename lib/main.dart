import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/providers/app_state.dart';
import 'src/providers/auth_provider.dart';
import 'src/theme/app_theme.dart';
import 'src/config/api_config.dart';
import 'src/services/siri_service.dart';
import 'src/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase using the official method
  await Supabase.initialize(
    url: ApiConfig.supabaseUrl,
    anonKey: ApiConfig.supabaseAnonKey,
  );

  // Initialize our Supabase service wrapper
  await SupabaseService.initialize();

  runApp(const SavrApp());
}

class SavrApp extends StatefulWidget {
  const SavrApp({super.key});

  @override
  State<SavrApp> createState() => _SavrAppState();
}

class _SavrAppState extends State<SavrApp> {
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _authProvider.initializeAuth();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider.value(value: _authProvider),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          // Initialize Siri service with context when app is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SiriService.initialize(context);
          });

          return MaterialApp.router(
            title: kIsWeb ? '.env' : 'Savr',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.themeMode,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}