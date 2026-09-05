import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/vehicle.dart';
import '../models/vehicle_type.dart';
import '../theme/app_theme.dart';

class RevenueScreen extends StatefulWidget {
  final VehicleType type;
  const RevenueScreen({super.key, required this.type});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _VehicleRevenue {
  final Vehicle vehicle;
  final double total;
  final int trips;
  _VehicleRevenue(this.vehicle, this.total, this.trips);
}

class _RevenueScreenState extends State<RevenueScreen> {
  List<_VehicleRevenue> _rows = [];
  double _grandTotal = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vehicles =
        await DatabaseHelper.instance.getAllVehicles(type: widget.type);
    final rentals =
        await DatabaseHelper.instance.getAllRentals(type: widget.type);
    final completed = rentals.where((r) => r.status == 'completed').toList();

    final rows = <_VehicleRevenue>[];
    double grand = 0;
    for (final vehicle in vehicles) {
      final vehicleRentals =
          completed.where((r) => r.vehicleId == vehicle.id).toList();
      final total =
          vehicleRentals.fold<double>(0, (sum, r) => sum + r.rentCharge);
      grand += total;
      if (vehicleRentals.isNotEmpty) {
        rows.add(_VehicleRevenue(vehicle, total, vehicleRentals.length));
      }
    }
    rows.sort((a, b) => b.total.compareTo(a.total));

    if (!mounted) return;
    setState(() {
      _rows = rows;
      _grandTotal = grand;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.type.label} Revenue')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total revenue',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(
                          '₹${_grandTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_rows.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          'No completed trips yet.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ..._rows.map(
                      (row) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                              child: Icon(widget.type.icon,
                                  color: AppColors.primaryRed),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(row.vehicle.model,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontSize: 15.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${row.vehicle.number} · ${row.trips} trip${row.trips == 1 ? '' : 's'}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${row.total.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
