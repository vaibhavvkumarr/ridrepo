import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/bike.dart';

class AddBikeScreen extends StatefulWidget {
  const AddBikeScreen({super.key});

  @override
  State<AddBikeScreen> createState() => _AddBikeScreenState();
}

class _AddBikeScreenState extends State<AddBikeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _numberController = TextEditingController();
  final _colourController = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final bike = Bike(
      model: _modelController.text.trim(),
      number: _numberController.text.trim().toUpperCase(),
      colour: _colourController.text.trim(),
    );
    await DatabaseHelper.instance.insertBike(bike);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add Bike')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _modelController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Bike model',
                  hintText: 'e.g. Honda Activa 6G',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter bike model' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Bike number',
                  hintText: 'e.g. MH12AB1234',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter bike number'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colourController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Colour',
                  hintText: 'e.g. Red',
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
                    : const Text('Save bike'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
