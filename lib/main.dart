import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'settings/currency_controller.dart';
import 'settings/vehicle_visibility_controller.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.load();
  await VehicleVisibilityController.instance.load();
  await CurrencyController.instance.load();
  await NotificationService.instance.init();
  await _resyncVehicleReminders();
  runApp(const RidrApp());
}

/// Re-schedules every vehicle's insurance/pollution expiry reminders on
/// launch, so they stay in sync even after the app is reinstalled/updated
/// or a manager edits dates outside the add-vehicle flow.
Future<void> _resyncVehicleReminders() async {
  final vehicles = await DatabaseHelper.instance.getAllVehicles();
  for (final vehicle in vehicles) {
    await NotificationService.instance.scheduleVehicleReminders(vehicle);
  }
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
