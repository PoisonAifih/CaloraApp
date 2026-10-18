import 'package:flutter/material.dart';

import '../theme/calora_theme.dart';

class CaloraCard extends StatelessWidget {
  const CaloraCard({required this.child, super.key, this.padding = const EdgeInsets.all(16), this.dark = false});

  final Widget child;
  final EdgeInsets padding;

  /// Forest "dark container" card for the item that needs attention most.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: dark ? CaloraColors.forest : CaloraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? CaloraColors.forest : CaloraColors.cream),
        boxShadow: const [caloraShadow],
      ),
      child: child,
    );
    if (!dark) return card;
    return DefaultTextStyle.merge(style: const TextStyle(color: CaloraColors.cream), child: card);
  }
}
