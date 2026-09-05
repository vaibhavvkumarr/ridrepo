import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/bike.dart';
import '../theme/app_theme.dart';
import 'rental_form_screen.dart';

class RentBikeScreen extends StatefulWidget {
  const RentBikeScreen({super.key});

  @override
  State<RentBikeScreen> createState() => _RentBikeScreenState();
}

class _RentBikeScreenState extends State<RentBikeScreen> {
  List<Bike> _bikes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bikes = await DatabaseHelper.instance.getAvailableBikes();
    if (!mounted) return;
    setState(() {
      _bikes = bikes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Bike')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _bikes.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No bikes available right now. Add a bike or wait for one to be returned.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _bikes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final bike = _bikes[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RentalFormScreen(bike: bike),
                            ),
                          );
                          _load();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.cardMuted),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.cardMuted,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.two_wheeler_rounded,
                                    color: AppColors.primaryRed),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(bike.model,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(fontSize: 15.5)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${bike.number} · ${bike.colour}',
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
