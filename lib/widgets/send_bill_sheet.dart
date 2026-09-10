import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/rental.dart';
import '../models/vehicle.dart';
import '../settings/currency_controller.dart';
import '../theme/app_theme.dart';

const _whatsappGreen = Color(0xFF25D366);

// Placeholder demo link — swap for the real Play Store listing later.
const _playStoreDemoLink = 'www.google.com';

String _formatBillDuration(Duration duration) {
  final minutes = duration.inMinutes;
  if (minutes <= 0) return '0 minutes';
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (hours == 0) return '$remainingMinutes minutes';
  if (remainingMinutes == 0) return '$hours ${hours == 1 ? 'hour' : 'hours'}';
  return '$hours ${hours == 1 ? 'hour' : 'hours'} $remainingMinutes minutes';
}

/// Builds the plain-text bill shared with a customer for [rental].
Future<String> buildBillText({
  required Rental rental,
  required Vehicle vehicle,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final ownerName = prefs.getString('owner_name') ?? '';
  final shopName = prefs.getString('shop_name') ?? 'Your shop';
  final currency = CurrencyController.instance.currency.value;
  final dateFormat = DateFormat('d MMM yyyy, h:mm a');

  final end = rental.actualReturnDateTime ?? rental.endDateTime;
  final duration = end.difference(rental.startDateTime);
  final total = rental.rentCharge + rental.deposit;

  final buffer = StringBuffer();
  buffer.writeln('🧾 Trip Bill — $shopName');
  if (ownerName.isNotEmpty) buffer.writeln('Managed by $ownerName');
  buffer.writeln();
  buffer.writeln('Customer: ${rental.customerName}');
  buffer.writeln('Age: ${rental.age}');
  buffer.writeln('Contact: ${rental.contactNumber}');
  buffer.writeln();
  buffer.writeln('Vehicle: ${vehicle.model} (${vehicle.number})');
  buffer.writeln('Trip start: ${dateFormat.format(rental.startDateTime)}');
  buffer.writeln('Trip end: ${dateFormat.format(end)}');
  buffer.writeln('Duration: ${_formatBillDuration(duration)}');
  buffer.writeln();
  buffer.writeln(
      'Rent charge: ${currency.symbol}${rental.rentCharge.toStringAsFixed(0)}');
  buffer.writeln(
      'Deposit: ${currency.symbol}${rental.deposit.toStringAsFixed(0)}');
  buffer.writeln('Total: ${currency.symbol}${total.toStringAsFixed(0)}');
  buffer.writeln();
  buffer.writeln('Thank you for choosing $shopName!');
  buffer.writeln();
  buffer.writeln('Generated with Ridr — making vehicle rentals effortless.');
  buffer.writeln('Download now: $_playStoreDemoLink');

  return buffer.toString();
}

String _whatsappNumber(String rawPhone) {
  final digits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 10) return '91$digits';
  return digits;
}

/// Shows a bottom sheet letting the manager share [rental]'s bill either
/// through the OS share sheet (SMS, Gmail, etc.) or directly to the
/// customer's number on WhatsApp.
Future<void> showSendBillSheet(
  BuildContext context, {
  required Rental rental,
  required Vehicle vehicle,
}) async {
  final billText = await buildBillText(rental: rental, vehicle: vehicle);
  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send bill to ${rental.customerName}',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Share the trip bill with the customer.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                Navigator.of(ctx).pop();
                await SharePlus.instance.share(ShareParams(text: billText));
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardMuted),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.ios_share_rounded,
                          color: AppColors.primaryRed),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Share bill',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('SMS, Gmail, and more',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                Navigator.of(ctx).pop();
                final number = _whatsappNumber(rental.contactNumber);
                final uri = Uri.parse(
                    'https://wa.me/$number?text=${Uri.encodeComponent(billText)}');
                final launched =
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                if (!launched && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open WhatsApp.')),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _whatsappGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: _whatsappGreen.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _whatsappGreen.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Icon(Icons.chat_rounded, color: _whatsappGreen),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Send on WhatsApp',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(rental.contactNumber,
                              style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: _whatsappGreen),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
