import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/vehicle.dart';

const _androidChannel = AndroidNotificationDetails(
  'vehicle_document_expiry',
  'Document expiry reminders',
  channelDescription:
      'Reminders when a vehicle\'s insurance or pollution certificate is about to expire',
  importance: Importance.high,
  priority: Priority.high,
);

/// Schedules a local reminder 2 days before a vehicle's insurance and
/// pollution certificate expiry dates.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Every call into the plugin is time-boxed: on some Android devices/OEM
  // skins the permission or alarm-scheduling channel call can hang instead
  // of erroring, and this service must never be able to block a caller
  // (e.g. saving a vehicle) that's merely trying to schedule a reminder as
  // a side effect.
  static const _pluginCallTimeout = Duration(seconds: 5);

  Future<void> init() async {
    if (_initialized) return;

    // No device timezone lookup needed: [_scheduleOne] builds the reminder
    // moment with the plain `DateTime()` constructor, which Dart already
    // resolves in the device's local time. `TZDateTime.from` preserves that
    // exact instant regardless of which [Location] it's labelled with, so
    // the default UTC-labelled `tz.local` fires at the correct real-world
    // moment without resolving an IANA timezone name.
    tz.initializeTimeZones();

    try {
      await _plugin
          .initialize(
            const InitializationSettings(
              android: AndroidInitializationSettings('@mipmap/ic_launcher'),
              iOS: DarwinInitializationSettings(),
            ),
          )
          .timeout(_pluginCallTimeout);

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission()
          .timeout(_pluginCallTimeout);
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true)
          .timeout(_pluginCallTimeout);
    } catch (e) {
      debugPrint('NotificationService.init failed, continuing without it: $e');
    }

    _initialized = true;
  }

  /// (Re)schedules the insurance/pollution expiry reminders for [vehicle],
  /// replacing any previously scheduled ones for the same vehicle. Never
  /// throws or hangs — a failure here should never stop a caller (e.g. the
  /// add-vehicle flow) from completing.
  Future<void> scheduleVehicleReminders(Vehicle vehicle) async {
    final id = vehicle.id;
    if (id == null) return;
    await _scheduleOne(
      id: id * 10 + 1,
      title: 'Insurance expiring soon',
      body: '${vehicle.model} (${vehicle.number}) insurance expires in 2 days.',
      expiry: vehicle.insuranceExpiry,
    );
    await _scheduleOne(
      id: id * 10 + 2,
      title: 'Pollution certificate expiring soon',
      body:
          '${vehicle.model} (${vehicle.number}) pollution certificate expires in 2 days.',
      expiry: vehicle.pollutionExpiry,
    );
  }

  /// Cancels any reminders scheduled for [vehicleId] (e.g. when the vehicle
  /// is deleted).
  Future<void> cancelVehicleReminders(int vehicleId) async {
    await _safeCancel(vehicleId * 10 + 1);
    await _safeCancel(vehicleId * 10 + 2);
  }

  Future<void> _safeCancel(int id) async {
    try {
      await _plugin.cancel(id).timeout(_pluginCallTimeout);
    } catch (e) {
      debugPrint('NotificationService.cancel($id) failed: $e');
    }
  }

  Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime? expiry,
  }) async {
    try {
      await _safeCancel(id);
      if (expiry == null) return;

      final reminderDay =
          DateTime(expiry.year, expiry.month, expiry.day - 2, 9);
      final scheduled = tz.TZDateTime.from(reminderDay, tz.local);
      if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

      await _plugin
          .zonedSchedule(
            id,
            title,
            body,
            scheduled,
            const NotificationDetails(
              android: _androidChannel,
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          )
          .timeout(_pluginCallTimeout);
    } catch (e) {
      debugPrint('NotificationService.scheduleOne($id) failed: $e');
    }
  }
}
