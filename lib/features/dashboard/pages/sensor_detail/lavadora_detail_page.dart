import 'package:flutter/material.dart';

class LavadoraDetailPage extends StatelessWidget {
  const LavadoraDetailPage({super.key});

  static const _assetMascota = 'assets/images/normal.png';
  static const _assetPanel   = 'assets/images/lavadora.png';

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF233E8B);
    const lightBlue = Color(0xFF5C77F2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ===== HEADER =====
          Container(
            width: double.infinity,
            height: 360,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [lightBlue, Color(0xFF91B1FF)],
              ),
            ),
            child: Align(
              alignment: const Alignment(0, 0.35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Ahorro de litros',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .6,
                      shadows: [
                        Shadow(
                          color: Color(0x33000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
                  _MascotaSticker(
                    assetPath: _assetMascota,
                    size: 136,
                    zoomCrop: 0.72,
                    panXPct: 0.12,
                  ),
                  SizedBox(height: 10),
                  _BigNumber(value: 610, unit: 'L'),
                ],
              ),
            ),
          ),

          // ===== PANEL =====
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 40),
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HOY',
                        style: TextStyle(
                          color: blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '0 L',
                        style: TextStyle(
                          color: blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Image.asset(_assetPanel, width: 118, height: 118),
                  const SizedBox(height: 30),
                  const _DataBadge(title: 'ESTA SEMANA', value: '90 L'),
                  SizedBox(height: 16),
                  const _DataBadge(title: 'ESTE MES', value: '450 L'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===== Widgets internos ===== */
class _BigNumber extends StatelessWidget {
  const _BigNumber({required this.value, required this.unit});
  final num value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final s = value % 1 == 0 ? value.toInt().toString() : value.toString();

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: s,
            style: const TextStyle(
              fontSize: 44,
              height: 1.0,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          TextSpan(
            text: ' $unit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: .95),
              shadows: const [
                Shadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotaSticker extends StatelessWidget {
  const _MascotaSticker({
    required this.assetPath,
    required this.size,
    this.zoomCrop = 0.74,
    this.panXPct = 0.12,
  });

  final String assetPath;
  final double size;
  final double zoomCrop;
  final double panXPct;

  @override
  Widget build(BuildContext context) {
    final w = size;
    return SizedBox(
      width: w,
      height: w,
      child: LayoutBuilder(
        builder: (context, c) {
          final leftoverW = c.maxWidth * (1 - zoomCrop);
          final dx = (leftoverW / 2) * panXPct.clamp(-1.0, 1.0);
          return ClipRect(
            child: Transform.translate(
              offset: Offset(dx, 0),
              child: Align(
                widthFactor: zoomCrop,
                heightFactor: zoomCrop,
                child: Image.asset(assetPath, fit: BoxFit.contain),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DataBadge extends StatelessWidget {
  final String title;
  final String value;

  const _DataBadge({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF233E8B);
    const lightBg = Color(0xFFEFF3FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: blue,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: blue,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
        ],
      ),
    );
  }
}
