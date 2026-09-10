import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'settings/currency_controller.dart';
import 'settings/vehicle_visibility_controller.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.load();
  await VehicleVisibilityController.instance.load();
  await CurrencyController.instance.load();
  runApp(const RidrApp());
}

class RidrApp extends StatelessWidget {
  const RidrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.instance.isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Ridr - Vehicle Rental Manager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
