import 'package:flutter/material.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_badge.dart';
import 'widgets/sensors_panel.dart';

class SensorsPage extends StatelessWidget {
  const SensorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ====== HEADER + ICONO FLOTANTE ======
          SizedBox(
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: const [
                DashboardHeader(height: 280),
                Positioned(top: 205, child: DashboardBadge()),
              ],
            ),
          ),

          // ====== PANEL DE SENSORES ======
          const Expanded(
            child: SensorsPanel(),
          ),
        ],
      ),
    );
  }
}
