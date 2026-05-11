import 'package:flutter/material.dart';
import '../shared/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        // Routes akan diisi per sesi
        AppRoutes.splash: (context) => const _SplashPlaceholder(),
        AppRoutes.login:  (context) => const _LoginPlaceholder(),
      },
    );
  }
}

// Placeholder — akan diganti di Sesi 2
class _SplashPlaceholder extends StatelessWidget {
  const _SplashPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Remunerasi Restoran\nSesi 1 — Setup Selesai ✅',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class _LoginPlaceholder extends StatelessWidget {
  const _LoginPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Login Screen — Sesi 2')),
    );
  }
}