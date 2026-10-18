import 'package:flutter/material.dart';

import '../theme/calora_theme.dart';

class CaloraCard extends StatelessWidget {
  const CaloraCard({required this.child, super.key, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: CaloraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CaloraColors.ink, width: 1.4),
      ),
      child: child,
    );
  }
}
