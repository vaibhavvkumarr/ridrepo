import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/bike.dart';
import '../theme/app_theme.dart';

class AllBikesScreen extends StatefulWidget {
  const AllBikesScreen({super.key});

  @override
  State<AllBikesScreen> createState() => _AllBikesScreenState();
}

class _AllBikesScreenState extends State<AllBikesScreen> {
  List<Bike> _bikes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bikes = await DatabaseHelper.instance.getAllBikes();
    if (!mounted) return;
    setState(() {
      _bikes = bikes;
      _loading = false;
    });
  }

  Future<void> _confirmDelete(Bike bike) async {
    if (bike.status == 'rented') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This bike is currently rented and can\'t be deleted.'),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete bike?'),
        content: Text(
          'Remove ${bike.model} (${bike.number}) from your fleet? This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper.instance.deleteBike(bike.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Bikes')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _bikes.isEmpty
                ? Center(
                    child: Text(
                      'No bikes added yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _bikes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final bike = _bikes[i];
                      final isRented = bike.status == 'rented';
                      return Container(
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
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isRented
                                    ? AppColors.danger.withValues(alpha: 0.12)
                                    : AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isRented ? 'Rented' : 'Available',
                                style: TextStyle(
                                  color: isRented
                                      ? AppColors.danger
                                      : AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  color: AppColors.textSecondary),
                              onPressed: () => _confirmDelete(bike),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
