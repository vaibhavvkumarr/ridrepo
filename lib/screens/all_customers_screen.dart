import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/bike.dart';
import '../models/rental.dart';
import '../theme/app_theme.dart';
import 'rental_detail_screen.dart';

class AllCustomersScreen extends StatefulWidget {
  const AllCustomersScreen({super.key});

  @override
  State<AllCustomersScreen> createState() => _AllCustomersScreenState();
}

class _AllCustomersScreenState extends State<AllCustomersScreen> {
  List<Rental> _rentals = [];
  Map<int, Bike> _bikesById = {};
  bool _loading = true;
  int? _selectedDays;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rentals = await DatabaseHelper.instance.getAllRentals();
    final bikes = await DatabaseHelper.instance.getAllBikes();
    if (!mounted) return;
    setState(() {
      _rentals = rentals;
      _bikesById = {for (final b in bikes) b.id!: b};
      _loading = false;
    });
  }

  String get _filterLabel =>
      _selectedDays == null ? 'Lifetime' : 'Last $_selectedDays days';

  List<Rental> get _filteredRentals {
    if (_selectedDays == null) return _rentals;

    final cutoff = DateTime.now().subtract(Duration(days: _selectedDays!));
    return _rentals
        .where((rental) => !rental.startDateTime.isBefore(cutoff))
        .toList();
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
    final rentals = _filteredRentals;
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
            : rentals.isEmpty
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
                    itemCount: rentals.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Text(
                          _filterLabel,
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      }
                      final rental = rentals[i - 1];
                      final bike = _bikesById[rental.bikeId];
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: bike == null
                            ? null
                            : () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RentalDetailScreen(
                                      rental: rental,
                                      bike: bike,
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
                                  rental.customerName.isNotEmpty
                                      ? rental.customerName[0].toUpperCase()
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
                                    Text(rental.customerName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(fontSize: 15.5)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${rental.contactNumber} · ${bike != null ? bike.number : 'Unknown bike'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dateFormat.format(rental.startDateTime),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
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
                    },
                  ),
      ),
    );
  }
}
