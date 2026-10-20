import 'package:flutter/material.dart';

import '../theme/calora_theme.dart';
import 'catering_screen.dart';
import 'home_screen.dart';
import 'log_meal_screen.dart';
import 'profile_screen.dart';
import 'workout_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  Future<void> _logMeal() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LogMealScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: [
            HomeScreen(
              onProfile: () => setState(() => _index = 3),
              onCatering: () => setState(() => _index = 1),
            ),
            const CateringScreen(),
            const WorkoutScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 104 + bottomInset,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 78 + bottomInset,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: CaloraColors.canvas,
                  border: Border(top: BorderSide(color: CaloraColors.cream)),
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: Row(
                    children: [
                      _tab(0, Icons.home_outlined, 'Home'),
                      _tab(1, Icons.restaurant_outlined, 'Catering'),
                      const Expanded(child: SizedBox()),
                      _tab(2, Icons.track_changes, 'Activity'),
                      _tab(3, Icons.more_horiz, 'Other'),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Material(
                color: CaloraColors.accent,
                shape: CircleBorder(side: BorderSide(color: CaloraColors.canvas, width: 5)),
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.35),
                child: InkWell(
                  onTap: _logMeal,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 70,
                    height: 70,
                    child: Icon(Icons.photo_camera_outlined, color: Colors.white, size: 30, semanticLabel: 'Foto makanan'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(int index, IconData icon, String label) {
    final selected = _index == index;
    final color = selected ? CaloraColors.heading : CaloraColors.inkMuted;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: selected ? CaloraColors.accent : Colors.transparent, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}
