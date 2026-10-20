import 'package:flutter/material.dart';

import '../api/calora_client.dart';
import '../api/models.dart';
import '../app.dart';
import '../theme/calora_theme.dart';
import '../update/update_prompt.dart';
import '../widgets/calora_card.dart';
import 'food_screen.dart';
import 'trends_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _bb = TextEditingController();
  final _tb = TextEditingController();
  final _age = TextEditingController();
  final _target = TextEditingController();
  final _rate = TextEditingController();
  final _allergies = TextEditingController();
  final _disliked = TextEditingController();
  String _sex = 'male';
  String _activity = 'moderate';
  String _goal = 'maintain';
  String _diet = 'none';
  String _timezone = 'Asia/Bangkok';
  bool _busy = false;
  bool _filled = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = CaloraScope.of(context).dashboard?.profile ?? CaloraScope.of(context).user?.profile;
    if (profile != null && !_filled) {
      _fill(profile);
      _filled = true;
    }
  }

  void _fill(Profile profile) {
    _bb.text = _trim(profile.bb);
    _tb.text = _trim(profile.tb);
    _age.text = profile.age.round().toString();
    _target.text = _trim(profile.targetWeightKg);
    _rate.text = _trim(profile.rateKgPerWeek);
    _allergies.text = profile.allergies;
    _disliked.text = profile.dislikedFoods;
    _sex = profile.sex;
    _activity = profile.activity;
    _goal = profile.goal;
    _diet = profile.dietaryPreference;
    _timezone = profile.timezone;
  }

  Widget _link(IconData icon, String label, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: CaloraColors.forest),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: CaloraColors.inkMuted),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(), body: SafeArea(top: false, child: screen))),
      ),
    );
  }

  String _trim(double value) => value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1);

  @override
  void dispose() {
    _bb.dispose();
    _tb.dispose();
    _age.dispose();
    _target.dispose();
    _rate.dispose();
    _allergies.dispose();
    _disliked.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bb = double.tryParse(_bb.text);
    final tb = double.tryParse(_tb.text);
    final age = double.tryParse(_age.text);
    final target = double.tryParse(_target.text);
    final rate = double.tryParse(_rate.text);
    if (bb == null || tb == null || age == null || target == null || rate == null) {
      setState(() => _error = 'Fill in weight, height, age, target, and rate');
      return;
    }
    final body = {
      'bb': bb,
      'tb': tb,
      'age': age,
      'sex': _sex,
      'activity': _activity,
      'goal': _goal,
      'targetWeightKg': target,
      'rateKgPerWeek': rate,
      'dietaryPreference': _diet,
      'allergies': _allergies.text,
      'dislikedFoods': _disliked.text,
      'timezone': _timezone,
    };
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await CaloraScope.of(context).client.saveProfile(body);
      if (mounted) await CaloraScope.of(context).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
      }
    } on CaloraException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        const Text('OTHER', style: CaloraText.title),
        const SizedBox(height: 12),
        CaloraCard(
          padding: EdgeInsets.zero,
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                _link(Icons.rice_bowl_outlined, 'Food log', const FoodScreen()),
                const Divider(height: 1, color: CaloraColors.cream),
                _link(Icons.show_chart, 'Trends', const TrendsScreen()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text('PROFILE', style: CaloraText.section),
        const SizedBox(height: 12),
        CaloraCard(
          child: Column(
            children: [
              _num(_bb, 'Weight kg'),
              _num(_tb, 'Height cm'),
              _num(_age, 'Age'),
              _choice('Sex', _sex, const ['male', 'female'], (value) => setState(() => _sex = value)),
              _choice('Activity', _activity, const ['sedentary', 'light', 'moderate', 'active'], (value) => setState(() => _activity = value)),
              _choice('Goal', _goal, const ['lose', 'maintain', 'gain'], (value) => setState(() => _goal = value)),
              _num(_target, 'Target weight kg'),
              _num(_rate, 'Rate kg per week'),
              _choice('Diet', _diet, const ['none', 'vegetarian', 'vegan', 'pescatarian'], (value) => setState(() => _diet = value)),
              TextField(controller: _allergies, decoration: const InputDecoration(labelText: 'Allergies')),
              const SizedBox(height: 12),
              TextField(controller: _disliked, decoration: const InputDecoration(labelText: 'Disliked foods')),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: CaloraColors.danger)),
              ],
              const SizedBox(height: 12),
              FilledButton(onPressed: _busy ? null : _save, child: const Text('Save profile')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            final updates = UpdateScope.maybeOf(context);
            if (updates != null) promptGithubUpdate(context, updates, force: true);
          },
          child: const Text('Check for updates'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: () => CaloraScope.of(context).logout(), child: const Text('Sign out')),
      ],
    );
  }

  Widget _num(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _choice(String label, String value, List<String> options, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        key: ValueKey('$label-$value'),
        initialValue: options.contains(value) ? value : options.first,
        decoration: InputDecoration(labelText: label),
        items: [for (final option in options) DropdownMenuItem(value: option, child: Text(option))],
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
      ),
    );
  }
}
