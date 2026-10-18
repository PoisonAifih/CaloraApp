import 'package:flutter/material.dart';

import '../api/calora_client.dart';
import '../app.dart';
import '../format.dart';
import '../theme/calora_theme.dart';
import '../widgets/calora_card.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _minutes = TextEditingController();
  final _exercise = TextEditingController();
  final _kg = TextEditingController();
  final _reps = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _minutes.dispose();
    _exercise.dispose();
    _kg.dispose();
    _reps.dispose();
    super.dispose();
  }

  Future<void> _saveSession() async {
    final minutes = int.tryParse(_minutes.text);
    if (minutes == null || minutes < 0) {
      _toast('Enter the session length in minutes');
      return;
    }
    await _send({
      'activityType': 'WORKOUT',
      'name': 'Workout Session',
      'startedAt': DateTime.now().toUtc().toIso8601String(),
      'durationSeconds': minutes * 60,
      'dataQuality': 'USER_REPORTED',
    });
    _minutes.clear();
  }

  Future<void> _saveSet() async {
    final name = _exercise.text.trim();
    if (name.isEmpty) {
      _toast('Enter an exercise name');
      return;
    }
    final kg = _kg.text.trim();
    final reps = _reps.text.trim();
    final label = [name, if (kg.isNotEmpty) '${kg}kg', if (reps.isNotEmpty) '× $reps'].join(kg.isNotEmpty && reps.isNotEmpty ? ' · ' : ' ');
    final composed = kg.isNotEmpty && reps.isNotEmpty ? '$name · ${kg}kg × $reps' : label;
    await _send({
      'activityType': 'STRENGTH',
      'name': composed,
      'startedAt': DateTime.now().toUtc().toIso8601String(),
      'dataQuality': 'USER_REPORTED',
    });
    _exercise.clear();
    _kg.clear();
    _reps.clear();
  }

  Future<void> _send(Map<String, dynamic> body) async {
    setState(() => _busy = true);
    try {
      await CaloraScope.of(context).client.createActivity(body);
      if (mounted) await CaloraScope.of(context).refresh();
    } on CaloraException catch (error) {
      _toast(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(String id) async {
    try {
      await CaloraScope.of(context).client.deleteActivity(id);
      if (mounted) await CaloraScope.of(context).refresh();
    } on CaloraException catch (error) {
      _toast(error.message);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final activities = [...?CaloraScope.of(context).dashboard?.activities]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return RefreshIndicator(
      onRefresh: CaloraScope.of(context).refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          const Text('WORKOUT', style: CaloraText.title),
          const SizedBox(height: 12),
          CaloraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('SESSION', style: CaloraText.section),
                const SizedBox(height: 8),
                TextField(controller: _minutes, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minutes')),
                const SizedBox(height: 12),
                FilledButton(onPressed: _busy ? null : _saveSession, child: const Text('Save session')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CaloraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('EXERCISE', style: CaloraText.section),
                const SizedBox(height: 8),
                TextField(controller: _exercise, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 12),
                TextField(controller: _kg, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight kg')),
                const SizedBox(height: 12),
                TextField(controller: _reps, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reps')),
                const SizedBox(height: 12),
                FilledButton(onPressed: _busy ? null : _saveSet, child: const Text('Save exercise')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final activity in activities) ...[
            CaloraCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(activity.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          [
                            activity.activityType,
                            formatWhen(activity.startedAt),
                            if (activity.durationSeconds != null) '${(activity.durationSeconds! / 60).round()} min',
                          ].join(' · '),
                          style: const TextStyle(color: CaloraColors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => _delete(activity.id), icon: const Icon(Icons.delete_outline, color: CaloraColors.danger)),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
