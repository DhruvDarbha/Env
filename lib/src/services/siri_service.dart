import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class SiriService {
  static const MethodChannel _channel = MethodChannel('com.env.siri');
  static BuildContext? _context;

  /// Initialize the Siri service with app context
  static void initialize(BuildContext context) {
    _context = context;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handle method calls from iOS
  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'handleDeepLink':
        final String url = call.arguments as String;
        await _handleDeepLink(url);
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} not implemented',
        );
    }
  }

  /// Handle deep link navigation
  static Future<void> _handleDeepLink(String url) async {
    if (_context == null) return;

    final uri = Uri.parse(url);

    switch (uri.host) {
      case 'siri-fruit-analysis':
        // Navigate to the Siri-specific fruit analysis screen
        GoRouter.of(_context!).push('/siri-fruit-analysis');
        break;
      default:
        // Handle other deep links or navigate to home
        GoRouter.of(_context!).go('/');
        break;
    }
  }

  /// Register Siri shortcuts (called from iOS)
  static Future<void> registerSiriShortcuts() async {
    try {
      await _channel.invokeMethod('registerShortcuts');
    } on PlatformException catch (e) {
      print('Failed to register Siri shortcuts: ${e.message}');
    }
  }

  /// Check if Siri shortcuts are available
  static Future<bool> isSiriAvailable() async {
    try {
      final bool available = await _channel.invokeMethod('isSiriAvailable');
      return available;
    } on PlatformException catch (e) {
      print('Failed to check Siri availability: ${e.message}');
      return false;
    }
  }
}