import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GuitaLogo extends StatelessWidget {
  const GuitaLogo({super.key, this.size = 64, this.bold = true});
  final double size;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF7ED957);
    const white = Colors.white;

    // Estilo base (relleno)
    final fill = GoogleFonts.comfortaa(
      fontSize: size,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
      color: white,
      height: 1,
      letterSpacing: .5,
    );

    // Pintura para “trazo” (contorno) que engorda el texto
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.06
      ..color = const Color(0x66FFFFFF); // halo/blanco suave

    // Estilo con trazo
    final stroke = fill.copyWith(foreground: strokePaint);

    Widget buildWord(TextStyle style, {Color? uColor}) {
      return RichText(
        text: TextSpan(
          style: style,
          children: [
            const TextSpan(text: 'G'),
            TextSpan(text: 'ü', style: TextStyle(color: uColor ?? white)),
            const TextSpan(text: 'ita'),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // 1) trazo (debajo) → engrosa
        buildWord(stroke, uColor: const Color(0x66FFFFFF)),
        // 2) relleno (encima)
        buildWord(fill, uColor: green),
      ],
    );
  }
}
