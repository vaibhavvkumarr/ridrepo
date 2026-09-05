import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database_helper.dart';
import '../models/vehicle.dart';
import '../models/vehicle_type.dart';
import '../settings/vehicle_visibility_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_widgets.dart';
import 'profile_screen.dart';
import 'vehicle_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _ownerName = '';
  String _shopName = '';
  List<Vehicle> _vehicles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final vehicles = await DatabaseHelper.instance.getAllVehicles();
    if (!mounted) return;
    setState(() {
      _ownerName = prefs.getString('owner_name') ?? '';
      _shopName = prefs.getString('shop_name') ?? '';
      _vehicles = vehicles;
      _loading = false;
    });
  }

  Future<void> _goTo(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ValueListenableBuilder<Set<VehicleType>>(
                  valueListenable:
                      VehicleVisibilityController.instance.visibleTypes,
                  builder: (context, visibleTypes, _) {
                    final visibleVehicles = _vehicles
                        .where((v) => visibleTypes.contains(v.type))
                        .toList();
                    final total = visibleVehicles.length;
                    final available = visibleVehicles
                        .where((v) => v.status == 'available')
                        .length;
                    final rented = visibleVehicles
                        .where((v) => v.status == 'rented')
                        .length;
                    final types = VehicleType.values
                        .where((t) => visibleTypes.contains(t))
                        .toList();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi, $_ownerName',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _shopName,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Profile',
                              icon: const Icon(Icons.menu_rounded),
                              onPressed: () => _goTo(const ProfileScreen()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
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
                                      value: '$total', label: 'All Vehicles'),
                                  StatPill(
                                      value: '$available',
                                      label: 'Available\nVehicles'),
                                  StatPill(value: '$rented', label: 'Rented'),
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
                            for (final type in types)
                              ActionTile(
                                label: type.pluralLabel,
                                icon: type.icon,
                                onTap: () => _goTo(
                                    VehicleDashboardScreen(type: type)),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
