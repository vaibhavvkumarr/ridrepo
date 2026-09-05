import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

const _supportEmail = 'kumarvaibhav349@gmail.com';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = <(String, String)>[
    (
      'How do I rent out a vehicle?',
      'From the home screen, tap the vehicle type (Bike, Car, Auto, Bus or Truck), then "Rent". Fill in the customer\'s details, add the verification photos, set the trip window and charges, then save the trip.',
    ),
    (
      'How do I end a trip when the vehicle is returned?',
      'Open the trip from "On Rent" or "All Customers" inside that vehicle type\'s dashboard, tap "End trip & receive", confirm, and rate the customer out of 5.',
    ),
    (
      'Where can I see all my vehicles and their status?',
      'Open a vehicle type\'s dashboard and tap "All Bikes/Cars/Autos/Buses/Trucks" — it lists every one you\'ve added along with whether it\'s available or currently rented.',
    ),
    (
      'How is revenue calculated?',
      'Each vehicle type\'s "Revenue" section totals the rent charges from its completed and active trips.',
    ),
    (
      'Can I track my staff and reminders?',
      'Yes — open the profile menu from the home screen to manage your staff list and jot down reminders in the notepad.',
    ),
    (
      'Is my data backed up anywhere?',
      'All data is stored securely on this device only. Using "Reset" in the profile menu permanently erases it, so use it with care.',
    ),
  ];

  Future<void> _emailSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {'subject': 'Ridr support request'},
    );
    final launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not open a mail app. Email us at $_supportEmail')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Frequently asked questions',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final faq in _faqs) ...[
              _FaqTile(question: faq.$1, answer: faq.$2),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardMuted,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Still stuck?',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Email us with any problem or query and we\'ll get back to you.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => _emailSupport(context),
                    icon: const Icon(Icons.mail_outline_rounded),
                    label: const Text(_supportEmail),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardMuted),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(question,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(answer,
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
