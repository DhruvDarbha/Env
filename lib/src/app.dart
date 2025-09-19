import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/consumer/consumer_dashboard.dart';
import 'screens/consumer/consumer_login.dart';
import 'screens/supplier/supplier_dashboard.dart';
import 'screens/supplier/supplier_login.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/chat/askenv_chat_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/photo_analysis_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/consumer-login',
        name: 'consumer-login',
        builder: (context, state) => const ConsumerLogin(),
      ),
      GoRoute(
        path: '/consumer',
        name: 'consumer',
        builder: (context, state) => const ConsumerDashboard(),
        redirect: (context, state) {
          final authProvider = context.read<AuthProvider>();
          if (!authProvider.isConsumerAuthenticated) {
            return '/consumer-login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/supplier-login',
        name: 'supplier-login',
        builder: (context, state) => const SupplierLogin(),
      ),
      GoRoute(
        path: '/supplier',
        name: 'supplier',
        builder: (context, state) => const SupplierDashboard(),
        redirect: (context, state) {
          final authProvider = context.read<AuthProvider>();
          if (!authProvider.isSupplierAuthenticated) {
            return '/supplier-login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/camera',
        name: 'camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/photo-analysis',
        name: 'photo-analysis',
        builder: (context, state) {
          final imagePath = state.extra as String?;
          if (imagePath == null) {
            return const Scaffold(
              body: Center(
                child: Text('No image provided'),
              ),
            );
          }
          return PhotoAnalysisScreen(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: '/askenv-chat',
        name: 'askenv-chat',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AskEnvChatScreen(
            imageContext: extra?['imageContext'] as String?,
            imagePath: extra?['imagePath'] as String?,
          );
        },
      ),
    ],
  );
}