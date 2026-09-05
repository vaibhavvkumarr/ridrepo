import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/customer.dart';
import '../models/rental.dart';
import '../theme/app_theme.dart';
import 'customer_detail_screen.dart';

class _CustomerSummary {
  final Customer customer;
  final List<Rental> rentals; // sorted newest first

  _CustomerSummary(this.customer, this.rentals);

  double? get averageRating {
    final rated = rentals.where((r) => r.rating != null).toList();
    if (rated.isEmpty) return null;
    return rated.map((r) => r.rating!).reduce((a, b) => a + b) / rated.length;
  }

  DateTime get lastRentalAt => rentals.first.startDateTime;
}

class AllCustomersScreen extends StatefulWidget {
  const AllCustomersScreen({super.key});

  @override
  State<AllCustomersScreen> createState() => _AllCustomersScreenState();
}

class _AllCustomersScreenState extends State<AllCustomersScreen> {
  List<Rental> _rentals = [];
  List<Customer> _customers = [];
  bool _loading = true;
  int? _selectedDays;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rentals = await DatabaseHelper.instance.getAllRentals();
    final customers = await DatabaseHelper.instance.getAllCustomers();
    if (!mounted) return;
    setState(() {
      _rentals = rentals;
      _customers = customers;
      _loading = false;
    });
  }

  String get _filterLabel =>
      _selectedDays == null ? 'Lifetime' : 'Last $_selectedDays days';

  List<_CustomerSummary> get _customerSummaries {
    final customersById = {for (final c in _customers) c.id!: c};
    final customerIdByAadhar = {
      for (final c in _customers) c.aadharNumber: c.id!
    };

    final cutoff = _selectedDays == null
        ? null
        : DateTime.now().subtract(Duration(days: _selectedDays!));

    final rentalsByCustomer = <int, List<Rental>>{};
    for (final rental in _rentals) {
      if (cutoff != null && rental.startDateTime.isBefore(cutoff)) continue;
      final customerId =
          rental.customerId ?? customerIdByAadhar[rental.aadharNumber];
      if (customerId == null) continue;
      rentalsByCustomer.putIfAbsent(customerId, () => []).add(rental);
    }

    final summaries = <_CustomerSummary>[];
    for (final entry in rentalsByCustomer.entries) {
      final customer = customersById[entry.key];
      if (customer == null) continue;
      final rentals = entry.value
        ..sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
      summaries.add(_CustomerSummary(customer, rentals));
    }
    summaries.sort((a, b) => b.lastRentalAt.compareTo(a.lastRentalAt));
    return summaries;
  }

  Future<void> _showFilterSheet() async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter customers',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final days in <int?>[7, 15, 30, null])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(days == null ? 'Lifetime' : 'Last $days days'),
                  trailing: (_selectedDays?.toString() ?? 'lifetime') ==
                          (days?.toString() ?? 'lifetime')
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primaryRed)
                      : null,
                  onTap: () =>
                      Navigator.of(context).pop(days?.toString() ?? 'lifetime'),
                ),
            ],
          ),
        ),
      ),
    );
    if (selection == null) return;
    if (!mounted) return;
    setState(() =>
        _selectedDays = selection == 'lifetime' ? null : int.parse(selection));
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');
    final summaries = _customerSummaries;
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Customers'),
        actions: [
          IconButton(
            tooltip: 'Filter customers',
            icon: Icon(
              Icons.filter_list_rounded,
              color: _selectedDays == null ? null : AppColors.primaryRed,
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : summaries.isEmpty
                ? Center(
                    child: Text(
                      _rentals.isEmpty
                          ? 'No customers yet.'
                          : 'No customers in $_filterLabel.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: summaries.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Text(
                          _filterLabel,
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      }
                      final summary = summaries[i - 1];
                      final customer = summary.customer;
                      final rentals = summary.rentals;
                      final hasActive =
                          rentals.any((r) => r.status == 'active');
                      final avgRating = summary.averageRating;
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CustomerDetailScreen(
                                customer: customer,
                                rentals: rentals,
                              ),
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
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.cardMuted,
                                child: Text(
                                  customer.name.isNotEmpty
                                      ? customer.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(customer.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(fontSize: 15.5)),
                                    const SizedBox(height: 2),
                                    Text(
                                      customer.contactNumber,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Last rented ${dateFormat.format(summary.lastRentalAt)}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: (hasActive
                                              ? AppColors.warning
                                              : AppColors.primaryRed)
                                          .withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Rented ${rentals.length}x',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: hasActive
                                            ? AppColors.warning
                                            : AppColors.primaryRed,
                                      ),
                                    ),
                                  ),
                                  if (avgRating != null) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded,
                                            color: AppColors.primaryRed,
                                            size: 15),
                                        const SizedBox(width: 2),
                                        Text(
                                          avgRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
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
