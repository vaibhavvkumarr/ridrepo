import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../db/database_helper.dart';
import '../models/vehicle.dart';
import '../models/vehicle_type.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

const _frequentColours = <(String, Color)>[
  ('Black', Colors.black),
  ('White', Colors.white),
  ('Red', Colors.red),
  ('Blue', Colors.blue),
  ('Grey', Colors.grey),
  ('Silver', Color(0xFFC0C0C0)),
  ('Green', Colors.green),
  ('Yellow', Colors.yellow),
  ('Orange', Colors.orange),
  ('Maroon', Color(0xFF800000)),
];

class AddVehicleScreen extends StatefulWidget {
  final VehicleType type;
  const AddVehicleScreen({super.key, required this.type});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _modelFocusNode = FocusNode();
  final _numberController = TextEditingController();
  final _colourController = TextEditingController();
  DateTime? _insuranceExpiry;
  DateTime? _pollutionExpiry;
  File? _photo;
  bool _saving = false;
  final _picker = ImagePicker();

  void _pickColour(String name) {
    setState(() => _colourController.text = name);
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.card,
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
    final fileName = 'vehicle_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final saved = await File(picked.path).copy('${dir.path}/$fileName');

    if (!mounted) return;
    setState(() => _photo = saved);
  }

  Future<void> _pickExpiryDate({required bool isInsurance}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (date == null) return;
    setState(() {
      if (isInsurance) {
        _insuranceExpiry = date;
      } else {
        _pollutionExpiry = date;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_insuranceExpiry == null || _pollutionExpiry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please select both the insurance and pollution expiry dates.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final vehicle = Vehicle(
      type: widget.type,
      model: _modelController.text.trim(),
      number: _numberController.text.trim().toUpperCase(),
      colour: _colourController.text.trim(),
      insuranceExpiry: _insuranceExpiry,
      pollutionExpiry: _pollutionExpiry,
      photoPath: _photo?.path,
    );
    final id = await DatabaseHelper.instance.insertVehicle(vehicle);
    if (!mounted) return;
    Navigator.of(context).pop();
    // Best-effort: reminder scheduling never blocks the save flow above —
    // NotificationService itself times out and swallows any plugin failure.
    unawaited(NotificationService.instance
        .scheduleVehicleReminders(vehicle.copyWith(id: id)));
  }

  @override
  void dispose() {
    _modelController.dispose();
    _modelFocusNode.dispose();
    _numberController.dispose();
    _colourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.type.label;
    return Scaffold(
      appBar: AppBar(title: Text('Add $label')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickPhoto,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardMuted,
                    borderRadius: BorderRadius.circular(14),
                    image: _photo != null
                        ? DecorationImage(
                            image: FileImage(_photo!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _photo == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                color: AppColors.textSecondary, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Add a photo (optional)',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Autocomplete<String>(
                textEditingController: _modelController,
                focusNode: _modelFocusNode,
                optionsBuilder: (value) {
                  if (value.text.isEmpty) return const Iterable<String>.empty();
                  final query = value.text.toLowerCase();
                  return widget.type.brandSuggestions
                      .where((b) => b.toLowerCase().startsWith(query));
                },
                onSelected: (selection) {
                  _modelController.text = selection;
                  _modelController.selection = TextSelection.collapsed(
                    offset: selection.length,
                  );
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: '$label model',
                      hintText: widget.type.modelHint,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter $label model'
                        : null,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.card,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Icon(Icons.north_west_rounded,
                                          size: 16,
                                          color: AppColors.textSecondary),
                                      const SizedBox(width: 10),
                                      Text(
                                        option,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _numberController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: '$label number',
                  hintText: 'e.g. MH12AB1234',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter $label number'
                    : null,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _frequentColours.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final entry = _frequentColours[index];
                    return _ColourChip(
                      name: entry.$1,
                      swatch: entry.$2,
                      selected: _colourController.text.trim().toLowerCase() ==
                          entry.$1.toLowerCase(),
                      onTap: () => _pickColour(entry.$1),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _colourController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Colour',
                  hintText: 'Tap a colour above, or type your own',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter colour' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ExpiryDateField(
                      label: 'Insurance',
                      date: _insuranceExpiry,
                      onTap: () => _pickExpiryDate(isInsurance: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExpiryDateField(
                      label: 'Pollution',
                      date: _pollutionExpiry,
                      onTap: () => _pickExpiryDate(isInsurance: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      )
                    : Text('Save $label'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpiryDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _ExpiryDateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yy');
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardMuted),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_rounded,
                    color: AppColors.primaryRed, size: 15),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? dateFormat.format(date!) : 'Select date',
              style: TextStyle(
                fontSize: 14,
                color: date != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColourChip extends StatelessWidget {
  final String name;
  final Color swatch;
  final bool selected;
  final VoidCallback onTap;

  const _ColourChip({
    required this.name,
    required this.swatch,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryRed.withValues(alpha: 0.12)
              : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryRed : AppColors.cardMuted,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: swatch,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardMuted),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: selected ? AppColors.primaryRed : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
