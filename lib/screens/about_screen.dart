import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('A note from the founder',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardMuted),
              ),
              child: const Text(
                'Hey there! 👋\n\n'
                'I built Ridr because I watched shop owners like you track rentals '
                'on scraps of paper and lose track of who had which bike. This app '
                'is my small way of making your day a little easier — one trip, '
                'one customer, one bike at a time.\n\n'
                'Thank you for trusting Ridr with your business. If anything '
                'feels off or you have an idea to make it better, I\'d genuinely '
                'love to hear from you.\n\n'
                'Ride safe,',
                style: TextStyle(height: 1.5, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 14),
            Text('— Vaibhav Kumar',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.primaryRed)),
            const Text('Founder, Ridr',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
