import 'package:flutter/material.dart';

// Importa todas las páginas de detalle
import '../pages/sensor_detail/lavamanos_detail_page.dart';
import '../pages/sensor_detail/ducha_detail_page.dart';
import '../pages/sensor_detail/inodoro_detail_page.dart';
import '../pages/sensor_detail/lavaplatos_detail_page.dart';
import '../pages/sensor_detail/lavadora_detail_page.dart';

class SensorsPanel extends StatelessWidget {
  const SensorsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    const lime = Color(0xFFB7F34D);
    const blue = Color(0xFF233E8B);

    final sensors = [
      (1, 'LAVAMANOS', Icons.wash),
      (2, 'DUCHA', Icons.shower),
      (3, 'INODORO', Icons.wc),
      (4, 'LAVAPLATOS', Icons.kitchen),
      (5, 'LAVADORA', Icons.local_laundry_service),
    ];

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height - 290,
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== encabezado =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'SENSORES',
                    style: TextStyle(
                      color: blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Elige una opción',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.settings, color: blue, size: 22),
            ],
          ),
          const SizedBox(height: 18),

          // ===== lista sensores =====
          Expanded(
            child: ListView.builder(
              itemCount: sensors.length,
              itemBuilder: (context, i) {
                final (n, name, icon) = sensors[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SensorButton(
                    number: n,
                    label: name,
                    icon: icon,
                    lime: lime,
                    blue: blue,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorButton extends StatelessWidget {
  final int number;
  final String label;
  final IconData icon;
  final Color lime;
  final Color blue;

  const _SensorButton({
    required this.number,
    required this.label,
    required this.icon,
    required this.lime,
    required this.blue,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        // Aquí definimos las rutas a cada página
        Widget page;
        switch (label) {
          case 'LAVAMANOS':
            page = const LavamanosDetailPage();
            break;
          case 'DUCHA':
            page = const DuchaDetailPage();
            break;
          case 'INODORO':
            page = const InodoroDetailPage();
            break;
          case 'LAVAPLATOS':
            page = const LavaplatosDetailPage();
            break;
          case 'LAVADORA':
            page = const LavadoraDetailPage();
            break;
          default:
            page = const LavaplatosDetailPage();
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: lime,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: blue, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: blue, size: 26),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: blue,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
