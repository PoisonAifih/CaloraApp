import 'package:flutter/material.dart';

import '../app.dart';
import '../format.dart';
import '../theme/calora_theme.dart';
import '../widgets/calorie_ring.dart';
import '../widgets/calora_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.onProfile, super.key});

  final VoidCallback onProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _page = PageController(viewportFraction: 0.88);
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = CaloraScope.of(context);
    final dash = store.dashboard;
    final initial = (store.user?.name.isNotEmpty ?? false) ? store.user!.name[0].toUpperCase() : 'C';
    return RefreshIndicator(
      onRefresh: store.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          Row(
            children: [
              InkWell(
                onTap: widget.onProfile,
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  backgroundColor: CaloraColors.ink,
                  foregroundColor: CaloraColors.navInk,
                  child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Text(store.user?.name ?? 'Calora', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('In focus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (dash == null)
            const CaloraCard(child: Text('Pull to load today.'))
          else ...[
            SizedBox(
              height: 230,
              child: PageView(
                controller: _page,
                onPageChanged: (value) => setState(() => _index = value),
                children: [
                  _slide(_today(dash)),
                  _slide(_tonight(dash)),
                  _slide(_tomorrow(dash)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final active = index == _index;
                return Container(
                  width: active ? 18 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: active ? CaloraColors.ink : CaloraColors.ink.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            const SizedBox(height: 22),
            const Text('At a glance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _glance('Goal', dash.goalLabel, '${_kg(dash.currentKg)} kg now', 'Target ${_kg(dash.targetKg)} kg')),
                const SizedBox(width: 12),
                Expanded(child: _glance('Macros', 'Left today', 'P ${roundNum(dash.remainingProtein)} g', 'C ${roundNum(dash.remainingCarbs)} g   F ${roundNum(dash.remainingFat)} g')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _slide(Widget child) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: child);
  }

  Widget _today(dynamic dash) {
    return CaloraCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Today', style: TextStyle(color: CaloraColors.inkMuted, fontWeight: FontWeight.w700)),
                Text(roundNum(dash.remainingKcal), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800, height: 1)),
                const Text('kcal left', style: TextStyle(color: CaloraColors.inkMuted)),
                const SizedBox(height: 8),
                Text('${roundNum(dash.consumedKcal)} eaten of ${roundNum(dash.targetKcal)}', style: const TextStyle(color: CaloraColors.inkMuted)),
              ],
            ),
          ),
          CalorieRing(consumed: dash.consumedKcal, target: dash.targetKcal),
        ],
      ),
    );
  }

  Widget _tonight(dynamic dash) {
    final meal = dash.tonight;
    return CaloraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Tonight', style: TextStyle(color: CaloraColors.inkMuted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (meal == null)
            const Text('Log a meal to get a suggestion.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))
          else ...[
            Text(meal.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('${roundNum(meal.kcal)} kcal', style: const TextStyle(fontSize: 20)),
            Text('P ${roundNum(meal.protein)} g   C ${roundNum(meal.carbs)} g   F ${roundNum(meal.fat)} g', style: const TextStyle(color: CaloraColors.inkMuted)),
          ],
        ],
      ),
    );
  }

  Widget _tomorrow(dynamic dash) {
    final lunch = dash.lunch;
    return CaloraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Tomorrow', style: TextStyle(color: CaloraColors.inkMuted, fontWeight: FontWeight.w700)),
          Text(roundNum(dash.effectiveDailyTarget), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, height: 1.05)),
          const Text('kcal target', style: TextStyle(color: CaloraColors.inkMuted)),
          const SizedBox(height: 8),
          Text(lunch == null ? 'Kitchen lunch not assigned yet.' : lunch.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          if (lunch != null)
            Text('${roundNum(lunch.calories)} kcal   P ${roundNum(lunch.proteinG)} g   C ${roundNum(lunch.carbsG)} g   F ${roundNum(lunch.fatG)} g', style: const TextStyle(color: CaloraColors.inkMuted)),
        ],
      ),
    );
  }

  Widget _glance(String title, String headline, String line, String detail) {
    return CaloraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: CaloraColors.inkMuted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(headline, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(line),
          Text(detail, style: const TextStyle(color: CaloraColors.inkMuted)),
        ],
      ),
    );
  }

  String _kg(double? value) => value == null ? '--' : value.toStringAsFixed(1);
}
