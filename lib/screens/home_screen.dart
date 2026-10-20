import 'package:flutter/material.dart';

import '../api/models.dart';
import '../app.dart';
import '../theme/calora_theme.dart';
import '../widgets/calorie_ring.dart';
import '../widgets/calora_card.dart';

String _thousands(num value) {
  final raw = value.round().abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < raw.length; i++) {
    if (i > 0 && (raw.length - i) % 3 == 0) buffer.write(',');
    buffer.write(raw[i]);
  }
  return buffer.toString();
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return 'C';
  return (parts[0][0] + (parts.length > 1 ? parts[1][0] : '')).toUpperCase();
}

String _tomorrowLabel() {
  const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  final date = DateTime.now().add(const Duration(days: 1));
  return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.onProfile, required this.onCatering, super.key});

  final VoidCallback onProfile;
  final VoidCallback onCatering;

  @override
  Widget build(BuildContext context) {
    final store = CaloraScope.of(context);
    final dash = store.dashboard;
    final name = store.user?.name ?? '';
    final firstName = name.trim().isEmpty ? '' : name.trim().split(RegExp(r'\s+')).first;
    return RefreshIndicator(
      onRefresh: store.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          Row(
            children: [
              InkWell(
                onTap: onProfile,
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: CaloraColors.forest,
                  foregroundColor: CaloraColors.onForest,
                  child: Text(_initials(name), style: const TextStyle(fontFamily: CaloraText.display, fontSize: 20, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName.isEmpty ? 'Halo 👋' : 'Halo, $firstName 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: CaloraColors.heading),
                    ),
                    Text('Semangat menjaga nutrisimu hari ini!', style: TextStyle(fontSize: 13, color: CaloraColors.inkMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: CaloraColors.cream,
                shape: StadiumBorder(side: BorderSide(color: CaloraColors.sand)),
                child: InkWell(
                  onTap: onCatering,
                  customBorder: const StadiumBorder(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: CaloraColors.heading, width: 1.6)),
                          child: Text('T', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: CaloraColors.heading)),
                        ),
                        const SizedBox(width: 6),
                        Text('${store.tokenBalance}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: CaloraColors.heading)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                shape: CircleBorder(side: BorderSide(color: CaloraColors.sand)),
                color: Colors.transparent,
                child: IconButton(
                  tooltip: 'Notifikasi',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belum ada notifikasi'))),
                  icon: Icon(Icons.notifications_none, color: CaloraColors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (dash == null)
            const CaloraCard(child: Text('Tarik ke bawah untuk memuat data hari ini.'))
          else ...[
            _energy(dash),
            const SizedBox(height: 30),
            Text('STATUS KATERING BESOK', style: CaloraText.section),
            const SizedBox(height: 14),
            _catering(dash),
          ],
        ],
      ),
    );
  }

  Widget _energy(Dashboard dash) {
    final left = dash.targetKcal - dash.consumedKcal;
    final over = left < 0;
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              CalorieRing(
                consumed: dash.consumedKcal,
                target: dash.targetKcal,
                size: 140,
                stroke: 11,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      child: Text(_thousands(dash.consumedKcal), style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: CaloraColors.ink, height: 1)),
                    ),
                    const SizedBox(height: 4),
                    Text('/ ${_thousands(dash.targetKcal)} kcal', style: TextStyle(fontSize: 12, color: CaloraColors.inkMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sisa kalori', style: TextStyle(fontSize: 14, color: CaloraColors.inkMuted)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(_thousands(left.abs()), style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: CaloraColors.ink, height: 1.15)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: over ? CaloraColors.warnSoft : CaloraColors.okSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(over ? Icons.warning_amber_rounded : Icons.check, size: 16, color: over ? CaloraColors.tomato : CaloraColors.heading),
                          const SizedBox(width: 6),
                          Text(
                            over ? 'kcal berlebih' : 'kcal tersisa',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: over ? CaloraColors.tomato : CaloraColors.heading),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _macro('Protein', dash.consumedProtein, dash.targetProtein, CaloraColors.protein),
          const SizedBox(height: 16),
          _macro('Karbohidrat', dash.consumedCarbs, dash.targetCarbs, CaloraColors.carbs),
          const SizedBox(height: 16),
          _macro('Lemak', dash.consumedFat, dash.targetFat, CaloraColors.fat),
        ],
      ),
    );
  }

  Widget _macro(String label, double value, double target, Color color) {
    final fraction = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
            Text('${value.round()}g / ${target.round()}g', style: TextStyle(fontSize: 14, color: CaloraColors.inkMuted)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: fraction, minHeight: 11, color: color, backgroundColor: CaloraColors.cream),
        ),
      ],
    );
  }

  Widget _catering(Dashboard dash) {
    final lunch = dash.lunch;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: CaloraColors.forest, borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 15, color: CaloraColors.onForest),
                    SizedBox(width: 6),
                    Text('MENU BESOK', style: TextStyle(fontFamily: CaloraText.display, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: CaloraColors.onForest)),
                  ],
                ),
              ),
              const Spacer(),
              Text(_tomorrowLabel(), style: TextStyle(fontSize: 14, color: CaloraColors.inkMuted)),
            ],
          ),
          const SizedBox(height: 14),
          Text(lunch?.name ?? 'Belum ada menu', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          if (lunch == null)
            Text('Menu besok muncul setelah paket catering aktif.', style: TextStyle(fontSize: 15, color: CaloraColors.inkMuted))
          else ...[
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 15, color: CaloraColors.inkMuted),
                children: [
                  const TextSpan(text: 'Makan siang · '),
                  TextSpan(text: '${_thousands(lunch.calories)} kcal', style: TextStyle(fontWeight: FontWeight.w700, color: CaloraColors.ink)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Protein ${lunch.proteinG.round()}g'),
                _chip('Karbo ${lunch.carbsG.round()}g'),
                _chip('Lemak ${lunch.fatG.round()}g'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: CaloraColors.cream, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CaloraColors.heading)),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: CaloraColors.canvas,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CaloraColors.cream),
      ),
      child: child,
    );
  }
}
