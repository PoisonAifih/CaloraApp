import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/calora_client.dart';
import '../api/models.dart';
import '../app.dart';
import '../theme/calora_theme.dart';

class LogMealScreen extends StatefulWidget {
  const LogMealScreen({this.manual = false, super.key});

  final bool manual;

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  final _picker = ImagePicker();
  final _name = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  String _category = 'snack';
  String _source = 'MANUAL';
  double _sugar = 0;
  double _sodium = 0;
  bool _busy = false;
  String? _error;
  String? _summary;

  @override
  void dispose() {
    _name.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1600);
    if (file == null || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final analysis = await CaloraScope.of(context).client.analyzePhoto(file.path);
      _apply(analysis);
    } on CaloraException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _apply(Analysis analysis) {
    _name.text = analysis.mealName;
    _kcal.text = analysis.kcal.round().toString();
    _protein.text = analysis.protein.round().toString();
    _carbs.text = analysis.carbs.round().toString();
    _fat.text = analysis.fat.round().toString();
    _sugar = analysis.sugar;
    _sodium = analysis.sodium;
    _source = analysis.source;
    _summary = analysis.summary;
    setState(() {});
  }

  Future<void> _save() async {
    final kcal = double.tryParse(_kcal.text);
    if (_name.text.trim().isEmpty || kcal == null || kcal <= 0) {
      setState(() => _error = 'Name and calories are required');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await CaloraScope.of(context).client.createFood({
        'meal': _name.text.trim(),
        'category': _category,
        'kcal': kcal,
        'protein': double.tryParse(_protein.text) ?? 0,
        'carbs': double.tryParse(_carbs.text) ?? 0,
        'fat': double.tryParse(_fat.text) ?? 0,
        'sugar': _sugar,
        'sodium': _sodium,
        'source': _source,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
      if (!mounted) return;
      await CaloraScope.of(context).refresh();
      if (mounted) Navigator.of(context).pop(true);
    } on CaloraException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LOG A MEAL')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          if (!widget.manual) ...[
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: _busy ? null : () => _pick(ImageSource.camera), icon: const Icon(Icons.photo_camera), label: const Text('Camera'))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(onPressed: _busy ? null : () => _pick(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text('Gallery'))),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (_busy) const LinearProgressIndicator(),
          if (_summary != null && _summary!.isNotEmpty) ...[
            Text(_summary!, style: const TextStyle(color: CaloraColors.inkMuted)),
            const SizedBox(height: 12),
          ],
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Meal')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: const [
              DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
              DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
              DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
              DropdownMenuItem(value: 'snack', child: Text('Snack')),
            ],
            onChanged: (value) => setState(() => _category = value ?? 'snack'),
          ),
          const SizedBox(height: 12),
          _number(_kcal, 'Calories'),
          const SizedBox(height: 12),
          _number(_protein, 'Protein g'),
          const SizedBox(height: 12),
          _number(_carbs, 'Carbs g'),
          const SizedBox(height: 12),
          _number(_fat, 'Fat g'),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: CaloraColors.danger)),
          ],
          const SizedBox(height: 16),
          FilledButton(onPressed: _busy ? null : _save, child: const Text('Save meal')),
        ],
      ),
    );
  }

  Widget _number(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    );
  }
}
