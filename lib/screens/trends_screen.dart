import 'package:flutter/material.dart';

import '../api/calora_client.dart';
import '../app.dart';
import '../format.dart';
import '../theme/calora_theme.dart';
import '../widgets/calora_card.dart';
import '../widgets/weight_chart.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final _weight = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final kg = double.tryParse(_weight.text);
    if (kg == null || kg < 30 || kg > 350) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weight must be between 30 and 350 kg')));
      return;
    }
    setState(() => _busy = true);
    try {
      await CaloraScope.of(context).client.createWeight({
        'weightKg': kg,
        'measuredAt': DateTime.now().toUtc().toIso8601String(),
        'source': 'MANUAL',
      });
      _weight.clear();
      if (mounted) await CaloraScope.of(context).refresh();
    } on CaloraException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dash = CaloraScope.of(context).dashboard;
    final weights = [...?dash?.weights]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final trend = dash?.weightTrend;
    return RefreshIndicator(
      onRefresh: CaloraScope.of(context).refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          const Text('Trends', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          CaloraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Weight kg'),
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: _busy ? null : _save, child: const Text('Save weight')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CaloraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trend == null ? 'Not enough weigh-ins for a trend' : '${trend > 0 ? '+' : ''}${trend.toStringAsFixed(2)} kg / week', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                WeightChart(weights: weights),
                Text('Average ${roundNum(dash?.averageCalories ?? 0)} kcal · protein ${roundNum(dash?.averageProtein ?? 0)} g'),
                Text('Logged ${dash?.daysLogged ?? 0} of ${dash?.windowDays ?? 7} days · confidence ${dash?.confidence ?? 'LOW'}'),
                Text('Activity energy ${roundNum(dash?.activityEnergyAverage ?? 0)} kcal/day', style: const TextStyle(color: CaloraColors.inkMuted)),
                Text('Logging completeness ${(((dash?.loggingCompleteness ?? 0) * 100).round())}%', style: const TextStyle(color: CaloraColors.inkMuted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final entry in weights.reversed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CaloraCard(
                child: Text('${entry.weightKg.toStringAsFixed(1)} kg · ${formatWhen(entry.measuredAt)}'),
              ),
            ),
        ],
      ),
    );
  }
}
