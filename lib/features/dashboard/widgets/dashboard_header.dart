import 'package:flutter/material.dart';
import 'package:guita/shared/widgets/guita_logo.dart';

class DashboardHeader extends StatelessWidget {
  final double height;
  const DashboardHeader({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    const lime = Color(0xFFB7F34D);

    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5C77F2), Color(0xFF91B1FF)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const GuitaLogo(size: 40),
          const SizedBox(height: 10),
          const Text(
            'Name Cat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: lime,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'VAAAS!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
