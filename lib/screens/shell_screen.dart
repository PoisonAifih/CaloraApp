import 'package:flutter/material.dart';

import '../theme/calora_theme.dart';
import 'food_screen.dart';
import 'home_screen.dart';
import 'log_meal_screen.dart';
import 'profile_screen.dart';
import 'trends_screen.dart';
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
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onProfile: () => setState(() => _index = 4)),
            const FoodScreen(),
            const WorkoutScreen(),
            const TrendsScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 92,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 68,
              child: ColoredBox(
                color: CaloraColors.ink,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _tab(0, Icons.home, 'Home'),
                    _tab(1, Icons.restaurant, 'Food'),
                    _tab(2, Icons.fitness_center, 'Workout'),
                    _tab(3, Icons.show_chart, 'Trends'),
                    _tab(4, Icons.person, 'Profile'),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: FloatingActionButton(
                onPressed: _logMeal,
                backgroundColor: CaloraColors.accent,
                foregroundColor: Colors.white,
                elevation: 4,
                child: const Icon(Icons.photo_camera),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(int index, IconData icon, String label) {
    final selected = _index == index;
    final color = selected ? CaloraColors.accent : CaloraColors.navInk;
    return InkWell(
      onTap: () => setState(() => _index = index),
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
