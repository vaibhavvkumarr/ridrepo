import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/rental.dart';
import '../models/vehicle.dart';
import '../models/vehicle_type.dart';
import '../theme/app_theme.dart';
import 'rental_detail_screen.dart';

class ActiveRentalsScreen extends StatefulWidget {
  final VehicleType type;
  const ActiveRentalsScreen({super.key, required this.type});

  @override
  State<ActiveRentalsScreen> createState() => _ActiveRentalsScreenState();
}

class _ActiveRentalsScreenState extends State<ActiveRentalsScreen> {
  List<Rental> _rentals = [];
  Map<int, Vehicle> _vehiclesById = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rentals =
        await DatabaseHelper.instance.getActiveRentals(type: widget.type);
    final vehicles =
        await DatabaseHelper.instance.getAllVehicles(type: widget.type);
    if (!mounted) return;
    setState(() {
      _rentals = rentals;
      _vehiclesById = {for (final v in vehicles) v.id!: v};
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM, h:mm a');
    final pluralLower = widget.type.pluralLabel.toLowerCase();
    return Scaffold(
      appBar: AppBar(title: Text('${widget.type.pluralLabel} On Rent')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _rentals.isEmpty
                ? Center(
                    child: Text(
                      'No $pluralLower are currently rented out.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _rentals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final rental = _rentals[i];
                        final vehicle = _vehiclesById[rental.vehicleId];
                        if (vehicle == null) return const SizedBox.shrink();
                        final overdue = rental.isOverdue;
                        final statusColor =
                            overdue ? AppColors.danger : AppColors.success;

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () async {
                            final changed = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RentalDetailScreen(
                                  rental: rental,
                                  vehicle: vehicle,
                                ),
                              ),
                            );
                            if (changed == true) _load();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: statusColor.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${vehicle.number} · ${vehicle.colour}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(fontSize: 15.5),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        rental.customerName,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        overdue
                                            ? 'Overdue since ${dateFormat.format(rental.endDateTime)}'
                                            : 'Due ${dateFormat.format(rental.endDateTime)}',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
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
      ),
    );
  }
}
