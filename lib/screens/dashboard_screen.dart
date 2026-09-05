import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_widgets.dart';
import 'add_bike_screen.dart';
import 'all_bikes_screen.dart';
import 'all_customers_screen.dart';
import 'profile_screen.dart';
import 'rent_bike_screen.dart';
import 'rent_leisure_screen.dart';
import 'revenue_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _ownerName = '';
  String _shopName = '';
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
    final prefs = await SharedPreferences.getInstance();
    final bikes = await DatabaseHelper.instance.getAllBikes();
    final available = bikes.where((b) => b.status == 'available').length;
    final rented = bikes.where((b) => b.status == 'rented').length;
    if (!mounted) return;
    setState(() {
      _ownerName = prefs.getString('owner_name') ?? '';
      _shopName = prefs.getString('shop_name') ?? '';
      _total = bikes.length;
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
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
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
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _shopName,
                                style: Theme.of(context).textTheme.bodyMedium,
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
                              StatPill(value: '$_total', label: 'All Bikes'),
                              StatPill(
                                  value: '$_available',
                                  label: 'Available\nBikes'),
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
                          label: 'Rent Bike',
                          icon: Icons.pedal_bike_rounded,
                          onTap: () => _goTo(const RentBikeScreen()),
                        ),
                        ActionTile(
                          label: 'Add Bike',
                          icon: Icons.add_circle_outline_rounded,
                          onTap: () => _goTo(const AddBikeScreen()),
                        ),
                        ActionTile(
                          label: 'Rent Leisure',
                          icon: Icons.pending_actions_rounded,
                          onTap: () => _goTo(const RentLeisureScreen()),
                        ),
                        ActionTile(
                          label: 'All Bikes',
                          icon: Icons.list_alt_rounded,
                          onTap: () => _goTo(const AllBikesScreen()),
                        ),
                        ActionTile(
                          label: 'Revenue',
                          icon: Icons.payments_rounded,
                          onTap: () => _goTo(const RevenueScreen()),
                        ),
                        ActionTile(
                          label: 'All Customers',
                          icon: Icons.people_alt_rounded,
                          onTap: () => _goTo(const AllCustomersScreen()),
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
