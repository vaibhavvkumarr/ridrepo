import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../db/database_helper.dart';
import '../models/bike.dart';
import '../models/rental.dart';
import '../theme/app_theme.dart';

class RentalFormScreen extends StatefulWidget {
  final Bike bike;
  const RentalFormScreen({super.key, required this.bike});

  @override
  State<RentalFormScreen> createState() => _RentalFormScreenState();
}

class _RentalFormScreenState extends State<RentalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  final _aadharController = TextEditingController();
  final _chargeController = TextEditingController();
  final _depositController = TextEditingController();

  File? _personBikePhoto;
  File? _licensePhoto;

  DateTime _startDateTime = DateTime.now();
  DateTime _endDateTime = DateTime.now().add(const Duration(hours: 4));

  bool _saving = false;
  final _picker = ImagePicker();

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes <= 0) return '0 minutes';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours == 0) return '$remainingMinutes minutes';
    if (remainingMinutes == 0) return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    return '$hours ${hours == 1 ? 'hour' : 'hours'} $remainingMinutes minutes';
  }

  Future<void> _pickImage(bool isPersonPhoto) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        '${isPersonPhoto ? 'person' : 'license'}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final saved = await File(picked.path).copy('${dir.path}/$fileName');

    setState(() {
      if (isPersonPhoto) {
        _personBikePhoto = saved;
      } else {
        _licensePhoto = saved;
      }
    });
  }

  Future<void> _pickDateTime(bool isStart) async {
    final initial = isStart ? _startDateTime : _endDateTime;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    final combined =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startDateTime = combined;
      } else {
        _endDateTime = combined;
      }
    });
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;
    if (_personBikePhoto == null) {
      _showError('Please add a photo of the person with the bike.');
      return;
    }
    if (_licensePhoto == null) {
      _showError('Please add a photo of the driving licence.');
      return;
    }
    if (_endDateTime.isBefore(_startDateTime)) {
      _showError('End date & time must be after start date & time.');
      return;
    }

    setState(() => _saving = true);

    final rental = Rental(
      bikeId: widget.bike.id!,
      customerName: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      contactNumber: _contactController.text.trim(),
      aadharNumber: _aadharController.text.trim(),
      personWithBikePhotoPath: _personBikePhoto!.path,
      licensePhotoPath: _licensePhoto!.path,
      startDateTime: _startDateTime,
      endDateTime: _endDateTime,
      rentCharge: double.parse(_chargeController.text.trim()),
      deposit: double.parse(_depositController.text.trim().isEmpty
          ? '0'
          : _depositController.text.trim()),
    );

    await DatabaseHelper.instance.insertRental(rental);
    await DatabaseHelper.instance.updateBikeStatus(widget.bike.id!, 'rented');

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _aadharController.dispose();
    _chargeController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM, h:mm a');
    return Scaffold(
      appBar: AppBar(title: const Text('Rent Bike')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardMuted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.two_wheeler_rounded,
                        color: AppColors.primaryRed),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.bike.model} · ${widget.bike.number} · ${widget.bike.colour}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('Customer details',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter age';
                        if (int.tryParse(v.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      decoration:
                          const InputDecoration(labelText: 'Contact number'),
                      validator: (v) => (v == null || v.trim().length < 10)
                          ? 'Enter valid number'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _aadharController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Aadhar card number'),
                validator: (v) => (v == null || v.trim().length < 4)
                    ? 'Enter Aadhar number'
                    : null,
              ),
              const SizedBox(height: 22),
              Text('Verification photos',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _PhotoPickerTile(
                      label: 'Person with bike',
                      file: _personBikePhoto,
                      onTap: () => _pickImage(true),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _PhotoPickerTile(
                      label: 'Driving licence',
                      file: _licensePhoto,
                      onTap: () => _pickImage(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text('Trip window',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              _DateTimeTile(
                label: 'Start',
                value: dateFormat.format(_startDateTime),
                onTap: () => _pickDateTime(true),
              ),
              const SizedBox(height: 10),
              _DateTimeTile(
                label: 'End',
                value: dateFormat.format(_endDateTime),
                onTap: () => _pickDateTime(false),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.cardMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_outlined,
                        color: AppColors.primaryRed),
                    const SizedBox(width: 10),
                    const Text('Total duration',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(
                      _endDateTime.isAfter(_startDateTime)
                          ? _formatDuration(
                              _endDateTime.difference(_startDateTime))
                          : 'Select a valid end time',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('Charges', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _chargeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Rent charge (₹)'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextFormField(
                      controller: _depositController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Deposit (₹)'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (double.tryParse(v.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saving ? null : _saveTrip,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      )
                    : const Text('Save trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPickerTile extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onTap;

  const _PhotoPickerTile({
    required this.label,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.cardMuted,
          borderRadius: BorderRadius.circular(16),
          image: file != null
              ? DecorationImage(image: FileImage(file!), fit: BoxFit.cover)
              : null,
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined,
                      color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 11.5),
                  ),
                ),
              ),
      ),
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardMuted),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule_rounded,
                color: AppColors.primaryRed, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(value, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
