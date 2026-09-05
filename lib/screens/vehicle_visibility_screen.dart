import 'package:flutter/material.dart';

import '../models/vehicle_type.dart';
import '../settings/vehicle_visibility_controller.dart';
import '../theme/app_theme.dart';

class VehicleVisibilityScreen extends StatelessWidget {
  const VehicleVisibilityScreen({super.key});

  Future<void> _toggle(
      BuildContext context, VehicleType type, bool value) async {
    final ok =
        await VehicleVisibilityController.instance.setVisible(type, value);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one vehicle type must stay visible.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Types')),
      body: SafeArea(
        child: ValueListenableBuilder<Set<VehicleType>>(
          valueListenable: VehicleVisibilityController.instance.visibleTypes,
          builder: (context, visible, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Choose which vehicle types show up as tiles on your home screen.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (final type in VehicleType.values) ...[
                _VehicleTypeTile(
                  type: type,
                  enabled: visible.contains(type),
                  onChanged: (value) => _toggle(context, type, value),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleTypeTile extends StatelessWidget {
  final VehicleType type;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _VehicleTypeTile({
    required this.type,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardMuted),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(type.icon, color: AppColors.primaryRed),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              type.pluralLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          Switch(
            value: enabled,
            activeThumbColor: AppColors.primaryRed,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
