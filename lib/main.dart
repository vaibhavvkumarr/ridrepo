import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const RidrApp());
}

class RidrApp extends StatelessWidget {
  const RidrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ridr - Bike Rental Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _LaunchGate(),
    );
  }
}

/// Decides whether to show onboarding or the dashboard on app start.
class _LaunchGate extends StatelessWidget {
  const _LaunchGate();

  Future<bool> _isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOnboarded(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!
            ? const DashboardScreen()
            : const OnboardingScreen();
      },
    );
  }
}
