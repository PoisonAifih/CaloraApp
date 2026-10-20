import 'package:flutter/material.dart';

import '../api/calora_client.dart';
import '../app.dart';
import '../format.dart';
import '../theme/calora_theme.dart';
import '../widgets/calora_card.dart';
import 'log_meal_screen.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = CaloraScope.of(context);
    final foods = [...?store.dashboard?.foods]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return RefreshIndicator(
      onRefresh: store.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          Row(
            children: [
              Expanded(child: Text('FOOD', style: CaloraText.title)),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LogMealScreen(manual: true))),
                child: const Text('Enter manually'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (foods.isEmpty) const CaloraCard(child: Text('No meals yet. Use the camera button to log one.')),
          for (final food in foods) ...[
            CaloraCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.meal, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('${food.category} · ${formatWhen(food.createdAt)}', style: TextStyle(color: CaloraColors.inkMuted)),
                        const SizedBox(height: 4),
                        Text('${roundNum(food.kcal)} kcal   P ${roundNum(food.protein)}   C ${roundNum(food.carbs)}   F ${roundNum(food.fat)}'),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _delete(context, food.id),
                    icon: Icon(Icons.delete_outline, color: CaloraColors.danger),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete meal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await CaloraScope.of(context).client.deleteFood(id);
      if (context.mounted) await CaloraScope.of(context).refresh();
    } on CaloraException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }
}
