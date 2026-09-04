import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/bike.dart';
import '../models/rental.dart';
import '../theme/app_theme.dart';

class RentalDetailScreen extends StatefulWidget {
  final Rental rental;
  final Bike bike;

  const RentalDetailScreen(
      {super.key, required this.rental, required this.bike});

  @override
  State<RentalDetailScreen> createState() => _RentalDetailScreenState();
}

class _RentalDetailScreenState extends State<RentalDetailScreen> {
  bool _ending = false;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes <= 0) return '0 minutes';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours == 0) return '$remainingMinutes minutes';
    if (remainingMinutes == 0) return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    return '$hours ${hours == 1 ? 'hour' : 'hours'} $remainingMinutes minutes';
  }

  Future<void> _endTrip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End trip?'),
        content: Text(
          'Mark ${widget.bike.model} (${widget.bike.number}) as returned by ${widget.rental.customerName}?\n\n'
          'Planned duration: ${_formatDuration(widget.rental.endDateTime.difference(widget.rental.startDateTime))}\n'
          'Total duration now: ${_formatDuration(DateTime.now().difference(widget.rental.startDateTime))}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('End trip'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _ending = true);
    await DatabaseHelper.instance
        .completeRental(widget.rental.id!, DateTime.now());
    await DatabaseHelper.instance
        .updateBikeStatus(widget.bike.id!, 'available');
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final rental = widget.rental;
    final bike = widget.bike;
    final dateFormat = DateFormat('d MMM yyyy, h:mm a');
    final overdue = rental.isOverdue;

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardMuted,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.two_wheeler_rounded,
                      color: AppColors.primaryRed),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bike.model,
                            style: Theme.of(context).textTheme.titleLarge),
                        Text('${bike.number} · ${bike.colour}',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  if (rental.status == 'active')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: overdue
                            ? AppColors.danger.withValues(alpha: 0.14)
                            : AppColors.success.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        overdue ? 'Overdue' : 'On time',
                        style: TextStyle(
                          color: overdue ? AppColors.danger : AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Customer', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _InfoRow(label: 'Name', value: rental.customerName),
            _InfoRow(label: 'Age', value: '${rental.age}'),
            _InfoRow(label: 'Contact', value: rental.contactNumber),
            _InfoRow(label: 'Aadhar number', value: rental.aadharNumber),
            const SizedBox(height: 22),
            Text('Trip window', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _InfoRow(
                label: 'Start', value: dateFormat.format(rental.startDateTime)),
            _InfoRow(
                label: 'End', value: dateFormat.format(rental.endDateTime)),
            _InfoRow(
              label: 'Planned duration',
              value: _formatDuration(
                rental.endDateTime.difference(rental.startDateTime),
              ),
            ),
            if (rental.actualReturnDateTime != null) ...[
              _InfoRow(
                label: 'Returned',
                value: dateFormat.format(rental.actualReturnDateTime!),
              ),
              _InfoRow(
                label: 'Actual duration',
                value: _formatDuration(
                  rental.actualReturnDateTime!.difference(rental.startDateTime),
                ),
              ),
            ],
            const SizedBox(height: 22),
            Text('Charges', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _InfoRow(
                label: 'Rent charge',
                value: '₹${rental.rentCharge.toStringAsFixed(0)}'),
            _InfoRow(
                label: 'Deposit',
                value: '₹${rental.deposit.toStringAsFixed(0)}'),
            const SizedBox(height: 22),
            Text('Verification photos',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PhotoView(
                    label: 'Person with bike',
                    path: rental.personWithBikePhotoPath,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _PhotoView(
                    label: 'Driving licence',
                    path: rental.licensePhotoPath,
                  ),
                ),
              ],
            ),
            if (rental.status == 'active') ...[
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _ending ? null : _endTrip,
                child: _ending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      )
                    : const Text('End trip & receive bike'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoView extends StatelessWidget {
  final String label;
  final String path;
  const _PhotoView({required this.label, required this.path});

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            child: file.existsSync()
                ? Image.file(file)
                : const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Photo not found'),
                  ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: file.existsSync()
                ? Image.file(file,
                    height: 120, width: double.infinity, fit: BoxFit.cover)
                : Container(
                    height: 120,
                    color: AppColors.cardMuted,
                    child: const Icon(Icons.broken_image_outlined,
                        color: AppColors.textSecondary),
                  ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
