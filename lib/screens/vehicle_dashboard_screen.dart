import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/vehicle_type.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_widgets.dart';
import 'active_rentals_screen.dart';
import 'add_vehicle_screen.dart';
import 'all_customers_screen.dart';
import 'all_vehicles_screen.dart';
import 'rent_vehicle_screen.dart';
import 'revenue_screen.dart';

/// The per-vehicle-type home screen, reached by tapping a vehicle type tile
/// on the main dashboard. Mirrors the original bike-only dashboard: stats
/// for this type, plus the same six actions, all scoped to [type].
class VehicleDashboardScreen extends StatefulWidget {
  final VehicleType type;
  const VehicleDashboardScreen({super.key, required this.type});

  @override
  State<VehicleDashboardScreen> createState() =>
      _VehicleDashboardScreenState();
}

class _VehicleDashboardScreenState extends State<VehicleDashboardScreen> {
  int _total = 0;
  int _available = 0;
  int _rented = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vehicles =
        await DatabaseHelper.instance.getAllVehicles(type: widget.type);
    final available = vehicles.where((v) => v.status == 'available').length;
    final rented = vehicles.where((v) => v.status == 'rented').length;
    if (!mounted) return;
    setState(() {
      _total = vehicles.length;
      _available = available;
      _rented = rented;
      _loading = false;
    });
  }

  Future<void> _goTo(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    return Scaffold(
      appBar: AppBar(title: Text(type.pluralLabel)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardMuted,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              StatPill(
                                  value: '$_total',
                                  label: 'All ${type.pluralLabel}'),
                              StatPill(
                                  value: '$_available',
                                  label: 'Available\n${type.pluralLabel}'),
                              StatPill(value: '$_rented', label: 'Rented'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.35,
                      children: [
                        ActionTile(
                          label: 'Rent ${type.label}',
                          icon: type.icon,
                          onTap: () =>
                              _goTo(RentVehicleScreen(type: type)),
                        ),
                        ActionTile(
                          label: 'Add ${type.label}',
                          icon: Icons.add_circle_outline_rounded,
                          onTap: () =>
                              _goTo(AddVehicleScreen(type: type)),
                        ),
                        ActionTile(
                          label: '${type.pluralLabel} On Rent',
                          icon: Icons.pending_actions_rounded,
                          onTap: () =>
                              _goTo(ActiveRentalsScreen(type: type)),
                        ),
                        ActionTile(
                          label: 'All ${type.pluralLabel}',
                          icon: Icons.list_alt_rounded,
                          onTap: () =>
                              _goTo(AllVehiclesScreen(type: type)),
                        ),
                        ActionTile(
                          label: 'Revenue',
                          icon: Icons.payments_rounded,
                          onTap: () => _goTo(RevenueScreen(type: type)),
                        ),
                        ActionTile(
                          label: 'All Customers',
                          icon: Icons.people_alt_rounded,
                          onTap: () =>
                              _goTo(AllCustomersScreen(type: type)),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
