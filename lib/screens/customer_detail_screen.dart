import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/bike.dart';
import '../models/customer.dart';
import '../models/rental.dart';
import '../theme/app_theme.dart';
import 'rental_detail_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;
  final List<Rental> rentals;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
    required this.rentals,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Map<int, Bike> _bikesById = {};
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
      _bikesById = {for (final b in bikes) b.id!: b};
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final rentals = widget.rentals;
    final dateFormat = DateFormat('d MMM yyyy, h:mm a');
    final rated = rentals.where((r) => r.rating != null).toList();
    final avgRating = rated.isEmpty
        ? null
        : rated.map((r) => r.rating!).reduce((a, b) => a + b) / rated.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Customer')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardMuted),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer.name,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 6),
                        Text('${customer.contactNumber} · Age ${customer.age}',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        Text('Govt. ID: ${customer.aadharNumber}',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Rented ${rentals.length} time${rentals.length == 1 ? '' : 's'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (avgRating != null)
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: AppColors.primaryRed, size: 18),
                                  const SizedBox(width: 2),
                                  Text(
                                    avgRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Rental history',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  for (final rental in rentals) ...[
                    _RentalHistoryTile(
                      rental: rental,
                      bike: _bikesById[rental.bikeId],
                      dateFormat: dateFormat,
                      onTap: _bikesById[rental.bikeId] == null
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RentalDetailScreen(
                                    rental: rental,
                                    bike: _bikesById[rental.bikeId]!,
                                  ),
                                ),
                              ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
      ),
    );
  }
}

class _RentalHistoryTile extends StatelessWidget {
  final Rental rental;
  final Bike? bike;
  final DateFormat dateFormat;
  final VoidCallback? onTap;

  const _RentalHistoryTile({
    required this.rental,
    required this.bike,
    required this.dateFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardMuted),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bike != null ? '${bike!.model} · ${bike!.number}' : 'Unknown bike',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(dateFormat.format(rental.startDateTime),
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (rental.rating != null)
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.primaryRed, size: 16),
                  const SizedBox(width: 2),
                  Text('${rental.rating}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 10),
                ],
              ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (rental.status == 'active'
                        ? AppColors.warning
                        : AppColors.success)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                rental.status == 'active' ? 'Active' : 'Done',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: rental.status == 'active'
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
