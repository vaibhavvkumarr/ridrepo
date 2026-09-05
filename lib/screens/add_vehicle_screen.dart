import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/vehicle.dart';
import '../models/vehicle_type.dart';
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
  final _numberController = TextEditingController();
  final _colourController = TextEditingController();
  bool _saving = false;

  void _pickColour(String name) {
    setState(() => _colourController.text = name);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final vehicle = Vehicle(
      type: widget.type,
      model: _modelController.text.trim(),
      number: _numberController.text.trim().toUpperCase(),
      colour: _colourController.text.trim(),
    );
    await DatabaseHelper.instance.insertVehicle(vehicle);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _modelController.dispose();
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
              TextFormField(
                controller: _modelController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: '$label model',
                  hintText: widget.type.modelHint,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter $label model'
                    : null,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              Text('Colour', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final entry in _frequentColours)
                    _ColourChip(
                      name: entry.$1,
                      swatch: entry.$2,
                      selected: _colourController.text.trim().toLowerCase() ==
                          entry.$1.toLowerCase(),
                      onTap: () => _pickColour(entry.$1),
                    ),
                ],
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
              const SizedBox(height: 28),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
