import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/vehicle.dart';
import '../theme/app_theme.dart';

/// Expiry status shown wherever a vehicle's core details are listed, so an
/// expired document stands out at a glance.
///
/// Defaults to a single compact "Insurance · Pollution" line. Pass
/// [expanded] for a clearer, two-line statement layout (used on the All
/// Vehicles list) where each document gets its own full sentence and its
/// own independent expired styling.
class VehicleDocumentDates extends StatelessWidget {
  final Vehicle vehicle;
  final double fontSize;
  final bool expanded;

  const VehicleDocumentDates({
    super.key,
    required this.vehicle,
    this.fontSize = 12.5,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DocumentLine(
            icon: Icons.security_rounded,
            label: 'Insurance',
            date: vehicle.insuranceExpiry,
            fontSize: fontSize,
          ),
          const SizedBox(height: 4),
          _DocumentLine(
            icon: Icons.eco_outlined,
            label: 'Pollution',
            date: vehicle.pollutionExpiry,
            fontSize: fontSize,
          ),
        ],
      );
    }

    final dateFormat = DateFormat('d MMM yyyy');
    final now = DateTime.now();

    String part(String label, DateTime? date) {
      return '$label: ${date != null ? dateFormat.format(date) : 'not set'}';
    }

    final insuranceExpired = vehicle.insuranceExpiry != null &&
        vehicle.insuranceExpiry!.isBefore(now);
    final pollutionExpired = vehicle.pollutionExpiry != null &&
        vehicle.pollutionExpiry!.isBefore(now);
    final anyExpired = insuranceExpired || pollutionExpired;

    return Text(
      '${part('Insurance', vehicle.insuranceExpiry)} · ${part('Pollution', vehicle.pollutionExpiry)}',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: anyExpired ? FontWeight.w700 : FontWeight.w500,
        color: anyExpired ? AppColors.danger : AppColors.textSecondary,
      ),
    );
  }
}

class _DocumentLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime? date;
  final double fontSize;

  const _DocumentLine({
    required this.icon,
    required this.label,
    required this.date,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');
    final now = DateTime.now();
    final expired = date != null && date!.isBefore(now);
    final color = expired ? AppColors.danger : AppColors.textSecondary;

    final statement = date == null
        ? '$label expiry not set'
        : expired
            ? '$label expired ${dateFormat.format(date!)}'
            : '$label expires ${dateFormat.format(date!)}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: fontSize + 3, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            statement,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: expired ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
