import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/vehicle.dart';
import '../models/vehicle_type.dart';
import '../theme/app_theme.dart';
import '../widgets/vehicle_document_dates.dart';
import 'rental_form_screen.dart';

class RentVehicleScreen extends StatefulWidget {
  final VehicleType type;
  const RentVehicleScreen({super.key, required this.type});

  @override
  State<RentVehicleScreen> createState() => _RentVehicleScreenState();
}

class _RentVehicleScreenState extends State<RentVehicleScreen> {
  List<Vehicle> _vehicles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vehicles =
        await DatabaseHelper.instance.getAvailableVehicles(widget.type);
    if (!mounted) return;
    setState(() {
      _vehicles = vehicles;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.type.label;
    final pluralLower = widget.type.pluralLabel.toLowerCase();
    return Scaffold(
      appBar: AppBar(title: Text('Select $label')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _vehicles.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No $pluralLower available right now. Add a $label or wait for one to be returned.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _vehicles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final vehicle = _vehicles[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RentalFormScreen(vehicle: vehicle),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Text(vehicle.model,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(fontSize: 15.5)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${vehicle.number} · ${vehicle.colour}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    VehicleDocumentDates(
                                        vehicle: vehicle, expanded: true),
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
