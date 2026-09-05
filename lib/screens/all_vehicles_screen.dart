import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/vehicle.dart';
import '../models/vehicle_type.dart';
import '../theme/app_theme.dart';
import '../widgets/vehicle_document_dates.dart';

class AllVehiclesScreen extends StatefulWidget {
  final VehicleType type;
  const AllVehiclesScreen({super.key, required this.type});

  @override
  State<AllVehiclesScreen> createState() => _AllVehiclesScreenState();
}

class _AllVehiclesScreenState extends State<AllVehiclesScreen> {
  List<Vehicle> _vehicles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vehicles =
        await DatabaseHelper.instance.getAllVehicles(type: widget.type);
    if (!mounted) return;
    setState(() {
      _vehicles = vehicles;
      _loading = false;
    });
  }

  Future<void> _confirmDelete(Vehicle vehicle) async {
    final label = widget.type.label.toLowerCase();
    if (vehicle.status == 'rented') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('This $label is currently rented and can\'t be deleted.'),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $label?'),
        content: Text(
          'Remove ${vehicle.model} (${vehicle.number}) from your fleet? This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper.instance.deleteVehicle(vehicle.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All ${widget.type.pluralLabel}')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _vehicles.isEmpty
                ? Center(
                    child: Text(
                      'No ${widget.type.pluralLabel.toLowerCase()} added yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _vehicles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final vehicle = _vehicles[i];
                      final isRented = vehicle.status == 'rented';
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.cardMuted),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
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
                                  child: Text(vehicle.model,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontSize: 15.5)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isRented
                                        ? AppColors.danger
                                            .withValues(alpha: 0.12)
                                        : AppColors.success
                                            .withValues(alpha: 0.12),
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
                                  onPressed: () => _confirmDelete(vehicle),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 56),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reg. no. ${vehicle.number}  ·  Colour: ${vehicle.colour}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  VehicleDocumentDates(
                                      vehicle: vehicle, expanded: true),
                                ],
                              ),
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
