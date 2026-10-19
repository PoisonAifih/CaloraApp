import 'package:flutter/material.dart';

import '../theme/calora_theme.dart';

class _Pack {
  const _Pack(this.id, this.name, this.title, this.kcal, this.weekly);
  final String id;
  final String name;
  final String title;
  final int kcal;
  final int weekly;
}

class _Topup {
  const _Topup(this.id, this.tokens, this.unit, this.total, {this.list, this.save, this.badge, this.best = false});
  final String id;
  final int tokens;
  final int unit;
  final int total;
  final int? list;
  final int? save;
  final String? badge;
  final bool best;
}

const _packs = [
  _Pack('p1', 'Package 1', 'Healthy Weight Loss', 429, 40),
  _Pack('p2', 'Package 2', 'High Protein Muscle Building', 634, 50),
];

const _topups = [
  _Topup('t20', 20, 25000, 500000),
  _Topup('t40', 40, 24000, 960000, list: 1000000, save: 40000, badge: 'Hemat 4%'),
  _Topup('t60', 60, 23000, 1380000, list: 1500000, save: 120000, badge: 'Paling Hemat! Diskon 8%', best: true),
];

class CateringScreen extends StatefulWidget {
  const CateringScreen({super.key});

  @override
  State<CateringScreen> createState() => _CateringScreenState();
}

class _CateringScreenState extends State<CateringScreen> {
  int _balance = 20;
  String _packageId = 'p1';
  DateTime _endsAt = DateTime(2026, 10, 28);
  String _topupId = 't60';
  int _weeks = 1;

  _Pack get _pack => _packs.firstWhere((item) => item.id == _packageId);

  int get _daysLeft {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = DateTime(_endsAt.year, _endsAt.month, _endsAt.day);
    final days = end.difference(start).inDays;
    return days < 0 ? 0 : days;
  }

  String _date(DateTime value) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  String _rp(int value) {
    final raw = value.toString();
    final buffer = StringBuffer('Rp ');
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) buffer.write('.');
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }

  Future<void> _openTopup() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: CaloraColors.canvas,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            final picked = _topups.firstWhere((item) => item.id == _topupId);
            return _sheet(
              title: 'TOP UP TOKEN',
              copy: 'Token dipakai untuk menukar paket menu mingguan. Paket lebih besar lebih hemat per token.',
              children: [
                for (final item in _topups)
                  _choice(
                    selected: item.id == _topupId,
                    best: item.best,
                    onTap: () => setSheet(() => _topupId = item.id),
                    title: '${item.tokens} Token',
                    subtitle: '${_rp(item.unit)} / token',
                    badge: item.badge,
                    badgeHot: item.best,
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (item.list != null) Text(_rp(item.list!), style: const TextStyle(decoration: TextDecoration.lineThrough, color: CaloraColors.inkMuted, fontSize: 12)),
                        Text(_rp(item.total), style: const TextStyle(fontWeight: FontWeight.w700)),
                        if (item.save != null) Text('Hemat ${_rp(item.save!)}', style: const TextStyle(color: CaloraColors.kiwi, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                _info('Saldo setelah top up: ${_balance + picked.tokens} Token. Metode bayar: QRIS.'),
                const SizedBox(height: 14),
                _pay('Bayar ${_rp(picked.total)}', () {
                  setState(() => _balance += picked.tokens);
                  Navigator.pop(context);
                }),
                _cancel(context),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openRedeem() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: CaloraColors.canvas,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            final pack = _packs.firstWhere((item) => item.id == _packageId);
            final cost = pack.weekly * _weeks;
            final after = _balance - cost;
            final short = after < 0;
            final next = _endsAt.add(Duration(days: _weeks * 7));
            return _sheet(
              title: 'TUKARKAN TOKEN',
              copy: 'Masa aktif saat ini sampai ${_date(_endsAt)}.',
              children: [
                const Text('PAKET', style: CaloraText.micro),
                const SizedBox(height: 8),
                for (final item in _packs)
                  _choice(
                    selected: item.id == _packageId,
                    onTap: () {
                      setSheet(() => _packageId = item.id);
                      setState(() {});
                    },
                    title: '${item.name} · ${item.title}',
                    subtitle: '${item.kcal} kcal rata-rata per meal',
                    trailing: Text('${item.weekly} Token/mgg', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                const SizedBox(height: 6),
                const Text('DURASI', style: CaloraText.micro),
                const SizedBox(height: 8),
                for (final weeks in [1, 2, 4])
                  _choice(
                    selected: weeks == _weeks,
                    onTap: () => setSheet(() => _weeks = weeks),
                    title: '$weeks minggu',
                    trailing: Text('${pack.weekly * weeks} Token', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: CaloraColors.cream, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      _line('Sisa Token Saat Ini', '$_balance Token'),
                      _line('Token yang Dibutuhkan', '$cost Token'),
                      _line('Sisa Setelah Transaksi', short ? 'Kurang ${after.abs()} Token' : '$after Token', warn: short),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: CaloraColors.cream, borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: CaloraColors.carrot, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dikirim ke · Rumah', style: TextStyle(fontWeight: FontWeight.w700)),
                            Text('Jl. Sudirman No. 45, Jakarta Selatan'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _info('Langganan baru berakhir pada ${_date(next)}. Alamat diubah di Other. ${short ? 'Token belum cukup, Anda akan diarahkan ke Top Up.' : 'Token cukup untuk penukaran ini.'}'),
                const SizedBox(height: 14),
                _pay('Tukarkan $cost Token', () {
                  Navigator.pop(context);
                  if (short) {
                    _openTopup();
                    return;
                  }
                  setState(() {
                    _balance -= cost;
                    _endsAt = next;
                  });
                }),
                _cancel(context),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pack = _pack;
    final left = _daysLeft;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        const Text('CATERING', style: CaloraText.title),
        const SizedBox(height: 4),
        const Text('Tukar token dengan paket menu mingguan', style: TextStyle(color: CaloraColors.inkMuted)),
        const SizedBox(height: 16),
        _darkCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SISA TOKEN SAYA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: CaloraColors.cream)),
                          child: const Text('T', style: TextStyle(fontFamily: CaloraText.display, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        Text('$_balance', style: CaloraText.stat(44).copyWith(color: CaloraColors.cream)),
                        const SizedBox(width: 6),
                        const Text('Token', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Paket 7 hari mulai 40 Token', style: TextStyle(color: CaloraColors.cream.withValues(alpha: 0.8), fontSize: 13)),
                  ],
                ),
              ),
              FilledButton(onPressed: _openTopup, child: const Text('+ Top Up')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _darkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: CaloraColors.kiwi, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(left > 0 ? 'LANGGANAN AKTIF' : 'LANGGANAN BERAKHIR', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Berakhir pada', style: TextStyle(fontSize: 13)),
              Text(_date(_endsAt).toUpperCase(), style: CaloraText.stat(32).copyWith(color: CaloraColors.cream)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _pill('${pack.name} · ${pack.title}'),
                  _pill('Sisa $left hari'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: _openRedeem, child: Text('Tukarkan ${pack.weekly} Token'))),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('KATALOG PAKET 7 HARI', style: CaloraText.section),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final item in _packs) ...[
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _packageId = item.id),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                    decoration: BoxDecoration(
                      color: item.id == _packageId ? CaloraColors.forest : CaloraColors.canvas,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: item.id == _packageId ? CaloraColors.forest : CaloraColors.cream),
                    ),
                    child: Column(
                      children: [
                        Text(item.name.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(fontFamily: CaloraText.display, fontWeight: FontWeight.w700, color: item.id == _packageId ? CaloraColors.cream : CaloraColors.heading)),
                        const SizedBox(height: 4),
                        Text(item.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: item.id == _packageId ? CaloraColors.cream : CaloraColors.inkMuted)),
                        const SizedBox(height: 6),
                        Text('${item.weekly} Token', style: TextStyle(fontWeight: FontWeight.w700, color: item.id == _packageId ? CaloraColors.cream : CaloraColors.ink)),
                      ],
                    ),
                  ),
                ),
              ),
              if (item != _packs.last) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }

  Widget _darkCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: CaloraColors.forest, borderRadius: BorderRadius.circular(16), boxShadow: const [caloraShadow]),
      child: DefaultTextStyle.merge(style: const TextStyle(color: CaloraColors.cream), child: child),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: CaloraColors.matcha, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

Widget _sheet({required String title, required String copy, required List<Widget> children}) {
  return SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: CaloraColors.cream, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 14),
          Text(title, style: CaloraText.title.copyWith(fontSize: 28)),
          const SizedBox(height: 6),
          Text(copy, style: const TextStyle(color: CaloraColors.inkMuted, fontSize: 13)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    ),
  );
}

Widget _choice({
  required bool selected,
  required VoidCallback onTap,
  required String title,
  required Widget trailing,
  String? subtitle,
  String? badge,
  bool badgeHot = false,
  bool best = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: selected ? CaloraColors.cream : CaloraColors.canvas,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: selected ? (best ? CaloraColors.carrot : CaloraColors.forest) : CaloraColors.cream, width: best && selected ? 2 : 1),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? CaloraColors.forest : Colors.transparent,
                      border: Border.all(color: selected ? CaloraColors.forest : CaloraColors.mutedGreen),
                    ),
                    child: selected ? const Icon(Icons.check, size: 14, color: CaloraColors.cream) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title.toUpperCase(), style: const TextStyle(fontFamily: CaloraText.display, fontWeight: FontWeight.w700, fontSize: 16, color: CaloraColors.heading)),
                        if (subtitle != null) Text(subtitle, style: const TextStyle(color: CaloraColors.inkMuted, fontSize: 12)),
                        if (badge != null)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: badgeHot ? CaloraColors.carrot : CaloraColors.sunshine, borderRadius: BorderRadius.circular(8)),
                            child: Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeHot ? Colors.white : CaloraColors.charcoal)),
                          ),
                      ],
                    ),
                  ),
                  trailing,
                ],
              ),
            ),
          ),
        ),
        if (best)
          const Positioned(
            top: -8,
            right: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(color: CaloraColors.carrot, borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text('BEST VALUE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _line(String label, String value, {bool warn = false}) {
  final style = TextStyle(color: warn ? CaloraColors.tomato : CaloraColors.ink, fontWeight: warn ? FontWeight.w600 : FontWeight.w500);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    ),
  );
}

Widget _info(String text) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: CaloraColors.cream, borderRadius: BorderRadius.circular(16)),
    child: Text(text, style: const TextStyle(color: CaloraColors.inkMuted, fontSize: 13)),
  );
}

Widget _pay(String label, VoidCallback onPressed) {
  return SizedBox(width: double.infinity, child: FilledButton(onPressed: onPressed, child: Text(label)));
}

Widget _cancel(BuildContext context) {
  return SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')));
}
