import 'package:flutter/material.dart';

class DashboardBadge extends StatelessWidget {
  const DashboardBadge({super.key});

  @override
  Widget build(BuildContext context) {
    const lime = Color(0xFFB7F34D);
    return Material(
      elevation: 8,
      shape: const CircleBorder(),
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          color: lime,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.priority_high, color: Colors.white, size: 30),
      ),
    );
  }
}
