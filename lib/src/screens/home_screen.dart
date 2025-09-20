import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/background_wrapper_splash.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
              actions: [
                IconButton(
                  onPressed: () => context.go('/voice-demo'),
                  icon: const Icon(Icons.mic),
                  tooltip: 'Voice Demo',
                ),
                IconButton(
                  onPressed: () => context.go('/dev-tools'),
                  icon: const Icon(Icons.developer_mode),
                  tooltip: 'Development Tools',
                ),
              ],
      ),
      body: BackgroundWrapperSplash(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Column(
            children: [
              const SizedBox(height: 550),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () => context.go('/consumer'),
                  child: Text(
                    'Consumers',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () => context.go('/supplier-login'),
                  child: Text(
                    'Suppliers',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}