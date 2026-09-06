import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database_helper.dart';
import '../models/app_currency.dart';
import '../models/rental.dart';
import '../models/vehicle.dart';
import '../models/vehicle_type.dart';
import '../settings/currency_controller.dart';
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
  List<Rental> _rentals = [];
  bool _loading = true;
  bool _showDailyStats = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final vehicles = await DatabaseHelper.instance.getAllVehicles();
    final rentals = await DatabaseHelper.instance.getAllRentals();
    if (!mounted) return;
    setState(() {
      _ownerName = prefs.getString('owner_name') ?? '';
      _shopName = prefs.getString('shop_name') ?? '';
      _vehicles = vehicles;
      _rentals = rentals;
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

                    final visibleRentals = _rentals
                        .where((r) => visibleTypes.contains(r.vehicleType))
                        .toList();
                    final now = DateTime.now();
                    bool isToday(DateTime dt) =>
                        dt.year == now.year &&
                        dt.month == now.month &&
                        dt.day == now.day;
                    final todaysCollection = visibleRentals
                        .where((r) =>
                            r.status == 'completed' &&
                            r.actualReturnDateTime != null &&
                            isToday(r.actualReturnDateTime!))
                        .fold<double>(0, (sum, r) => sum + r.rentCharge);
                    final returningToday = visibleRentals
                        .where((r) =>
                            r.status == 'active' && isToday(r.endDateTime))
                        .length;
                    final depositHeld = visibleRentals
                        .where((r) => r.status == 'active')
                        .fold<double>(0, (sum, r) => sum + r.deposit);

                    return ValueListenableBuilder<AppCurrency>(
                      valueListenable: CurrencyController.instance.currency,
                      builder: (context, currency, __) {
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
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
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.cardMuted),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dashboard',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 20),
                                  IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _DashboardStat(
                                            value: '$total',
                                            label: 'All Vehicles',
                                          ),
                                        ),
                                        const _StatDivider(),
                                        Expanded(
                                          child: _DashboardStat(
                                            value: '$available',
                                            label: 'Available',
                                            valueColor: AppColors.success,
                                          ),
                                        ),
                                        const _StatDivider(),
                                        Expanded(
                                          child: _DashboardStat(
                                            value: '$rented',
                                            label: 'Rented',
                                            valueColor: rented > 0
                                                ? AppColors.primaryRed
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => setState(() =>
                                          _showDailyStats = !_showDailyStats),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _showDailyStats
                                                  ? 'Less details'
                                                  : 'More details',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            AnimatedRotation(
                                              turns: _showDailyStats ? 0.5 : 0,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              child: Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color: AppColors.textSecondary,
                                                size: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeInOut,
                                    alignment: Alignment.topCenter,
                                    child: !_showDailyStats
                                        ? const SizedBox(width: double.infinity)
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Divider(
                                                  color: AppColors.cardMuted,
                                                  height: 1),
                                              const SizedBox(height: 14),
                                              DashboardStatRow(
                                                icon: Icons.payments_outlined,
                                                label: "Today's Collection",
                                                value:
                                                    '${currency.symbol}${todaysCollection.toStringAsFixed(0)}',
                                              ),
                                              const SizedBox(height: 10),
                                              DashboardStatRow(
                                                icon: Icons
                                                    .assignment_return_outlined,
                                                label: 'Returns Today',
                                                value: '$returningToday',
                                              ),
                                              const SizedBox(height: 10),
                                              DashboardStatRow(
                                                icon: Icons
                                                    .account_balance_wallet_outlined,
                                                label: 'Deposit Held',
                                                value:
                                                    '${currency.symbol}${depositHeld.toStringAsFixed(0)}',
                                              ),
                                            ],
                                          ),
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
                    );
                  },
                ),
        ),
      ),
    );
  }
}

/// Single "value + label" column used in the redesigned Dashboard stat row.
class _DashboardStat extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _DashboardStat({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Thin vertical rule between Dashboard stat columns.
class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.cardMuted,
    );
  }
}
